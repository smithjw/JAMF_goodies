#!/bin/bash
# A lot of this code was reused from https://github.com/homebysix/jss-filevault-reissue

LOGO_ICNS="/Library/Application Support/CAmperIT/enso@512.png"
# Convert POSIX path of logo icon to Mac path for AppleScript
LOGO_ICNS="$(osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO_ICNS"'" as text')"
PROMPT_TITLE="Change my Slack Username"

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

# Get information necessary to display messages in the current user's context.
USER_ID=$(id -u "$CURRENT_USER")
if [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -le 9 ]]; then
    L_ID=$(pgrep -x -u "$USER_ID" loginwindow)
    L_METHOD="bsexec"
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -gt 9 ]]; then
    L_ID=USER_ID
    L_METHOD="asuser"
fi

usernameNew="$(launchctl "$L_METHOD" "$L_ID" osascript -e 'display dialog "Please enter a new Slack username" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result')"

# Curl variables
curl='/usr/bin/curl'
url="$5"

# you can store the result in a variable
zap="$($curl -X POST -F token="$4" -F current="$3@cultureamp.com" -F new="$usernameNew" $url)"

echo "$zap"

"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType utility -windowPosition c -title "Change Slack Username" -description "Thanks, your username has now been updated.

This may take a few moments to be reflected in Slack." -alignDescription left -icon "/Library/Application Support/CAmperIT/enso@512.png" -button1 "Ok"

exit 0
