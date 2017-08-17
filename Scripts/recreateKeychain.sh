#!/bin/bash

###
#
#            Name:  recreateKeychain.sh
#     Description:  This script deletes the user's login.keychain, prompts
#                   the current user for their password, and then creates
#                   a new keychain. Uses Applescript dialog and jamfHelper
#                   for notifications and password prompt.
#            Note:  Password prompt via Applescript from Elliot Jordan (github.com/homebysix),
#                   original keychain delete/recreate script by Andrina Kelly (github.com/andrina).
#          Author:  Emily Kausalik <drkausalik@gmail.com>
#         Created:  2016-12-29
#   Last Modified:  2016-12-29
#         Version:  0.9
#
###

################################## VARIABLES ##################################

# Your company's logo, in PNG format. (For use in jamfHelper messages.)
# Use standard UNIX path format:  /path/to/file.png
LOGO_PNG="/Library/Application Support/CAmperIT/enso@512.png"

# Your company's logo, in ICNS format. (For use in AppleScript messages.)
# Use standard UNIX path format:  /path/to/file.icns
LOGO_ICNS="/Library/Application Support/CAmperIT/enso@512.icns"

# The title of the message that will be displayed to the user.
# Not too long, or it'll get clipped.
PROMPT_TITLE="Keychain Repair"

# The body of the message that will be displayed before prompting the user for
# their password. All message strings below can be multiple lines.
PROMPT_MESSAGE="We will now repair your login Keychain on this Mac.
Click the Next button below, then enter your Mac's password when prompted."

# The body of the message that will be displayed after 5 incorrect passwords.
FORGOT_PW_MESSAGE="You have made five incorrect password attempts.
Please drop a message in #help_it on Slack for help with your Mac password."

# The body of the message that will be displayed after successful completion.
SUCCESS_MESSAGE="Thank you! Your Keychain has been repaired."

######################## VALIDATION AND ERROR CHECKING ########################

# Suppress errors for the duration of this script. (This prevents JAMF Pro from
# marking a policy as "failed" if the words "fail" or "error" inadvertently
# appear in the script output.)
exec 2>/dev/null

BAIL=false

# Make sure the custom logos have been received successfully
if [[ ! -f "$LOGO_ICNS" ]]; then
    echo "[ERROR] Custom logo icon not present: $LOGO_ICNS"
    BAIL=true
fi
if [[ ! -f "$LOGO_PNG" ]]; then
    echo "[ERROR] Custom logo PNG not present: $LOGO_PNG"
    BAIL=true
fi

# Convert POSIX path of logo icon to Mac path for AppleScript
LOGO_ICNS="$(osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO_ICNS"'" as text')"

# Bail out if jamfHelper doesn't exist.
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ ! -x "$jamfHelper" ]]; then
    echo "[ERROR] jamfHelper not found."
    BAIL=true
fi

# Check the OS version.
OS_MAJOR=$(sw_vers -productVersion | awk -F . '{print $1}')
OS_MINOR=$(sw_vers -productVersion | awk -F . '{print $2}')
if [[ "$OS_MAJOR" -ne 10 || "$OS_MINOR" -lt 9 ]]; then
    echo "[ERROR] OS version not 10.9+ or OS version unrecognized."
    sw_vers -productVersion
    BAIL=true
fi

# Get the logged in user's name
CURRENT_USER="$(stat -f%Su /dev/console)"

################################ MAIN PROCESS #################################

# Get information necessary to display messages in the current user's context.
USER_ID=$(id -u "$CURRENT_USER")
if [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -le 9 ]]; then
    L_ID=$(pgrep -x -u "$USER_ID" loginwindow)
    L_METHOD="bsexec"
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -gt 9 ]]; then
    L_ID=USER_ID
    L_METHOD="asuser"
fi

# Display a branded prompt explaining the password prompt.
echo "Alerting user $CURRENT_USER about incoming password prompt..."
launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "hud" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE" -button1 "Next" -defaultButton 1 -startlaunchd &>/dev/null

# Get the name of the users keychain - some messy sed and awk to set up the correct name for security to like
KEYCHAIN=$(su $CURRENT_USER -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}')

# Go delete the keychain in question...
su $CURRENT_USER -c "security delete-keychain $KEYCHAIN"

# Get the logged in user's password via a prompt.
echo "Prompting $CURRENT_USER for their Mac password..."
USER_PASS="$(launchctl "$L_METHOD" "$L_ID" osascript -e 'display dialog "Please enter the password you use to log in to your Mac:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result')"

# Thanks to James Barclay (@futureimperfect) for this password validation loop.
TRY=1
until dscl /Search -authonly "$CURRENT_USER" "$USER_PASS" &>/dev/null; do
    (( TRY++ ))
    echo "Prompting $CURRENT_USER for their Mac password (attempt $TRY)..."
    USER_PASS="$(launchctl "$L_METHOD" "$L_ID" osascript -e 'display dialog "Sorry, that password was incorrect. Please try again:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result')"
    if (( TRY >= 5 )); then
        echo "[ERROR] Password prompt unsuccessful after 5 attempts. Displaying \"forgot password\" message..."
        launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$FORGOT_PW_MESSAGE" -button1 'OK' -defaultButton 1 -timeout 30 -startlaunchd &>/dev/null &
        exit 1
    fi
done
echo "Successfully prompted for Mac password."

# Translate XML reserved characters to XML friendly representations.
# Thanks @AggroBoy! - https://gist.github.com/AggroBoy/1242257
USER_PASS_XML=$(echo "$USER_PASS" | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g' -e 's~>~\&gt;~g' -e 's~\"~\&quot;~g' -e "s~\'~\&apos;~g" )

# Create the new login keychain
expect <<- DONE
  set timeout -1
  spawn su $CURRENT_USER -c "security create-keychain login.keychain"

  # Look for prompt
  expect "*?chain:*"
  # Send user-entered password from prompt
  send "$USER_PASS_XML\n"
  expect "*?chain:*"
  send "$USER_PASS_XML\r"
  expect EOF
DONE

# Set the newly created login.keychain as the users default keychain
su $CURRENT_USER -c "security default-keychain -s login.keychain"

echo "Displaying \"success\" message..."
launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$SUCCESS_MESSAGE" -button1 'OK' -defaultButton 1 -timeout 30 -startlaunchd &>/dev/null &

exit 0
