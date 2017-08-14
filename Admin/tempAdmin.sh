#!/bin/bash

# This script will give a user 30 minutes of Admin level access, from Jamf's self service.
# At the end of the 30 minutes it will then call a jamf policy with a manual trigger. 
# Remove the users admin rights and disable the plist file this creates and activities.

# Original script by Andrina Kelly : https://github.com/andrina/JNUC2013/blob/master/Users%20Do%20Your%20Job/MakeMeAdmin/
# Updated by Richard Purves - 13th February 2017 - richard at richard - purves dot com

# Define variables and logging here
USERNAME=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
COMPANY="com.cultureamp.adminremove"
REMOVELD="/Library/LaunchDaemons/$COMPANY.plist"
TMPLOC="/usr/local/cultureamp/misc"
LOGFOLDER="/private/var/log/cultureamp"
LOG=$LOGFOLDER"TempAdminRights.log"
LOGO_ICNS="/Library/Application Support/CAmperIT/enso@512.icns"

if [ ! -d "$LOGFOLDER" ];
then
	mkdir $LOGFOLDER
fi

if [ ! -d "$TMPLOC" ];
then
	mkdir -p $TMPLOC
fi

function logme()
{
# Check to see if function has been called correctly
	if [ -z "$1" ]
	then
		echo $( date "+Date:%d-%m-%Y TIME:%H:%M:%S" )" - logme function call error: no text passed to function! Please recheck code!"
		echo $( date "+Date:%d-%m-%Y TIME:%H:%M:%S" )" - logme function call error: no text passed to function! Please recheck code!" >> $LOG
		exit 1
	fi

# Log the passed details
	echo -e $( date "+Date:%d-%m-%Y TIME:%H:%M:%S" )" - $1" >> $LOG
	echo -e $( date "+Date:%d-%m-%Y TIME:%H:%M:%S" )" - $1"
}

# Identify location of jamf binary. Code curtesy of Rich Trouton. https://derflounder.wordpress.com/2015/09/24/path-environment-variables-and-casper-9-8/#more-7176

jamf_binary=`/usr/bin/which jamf`

 if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/sbin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 fi


# Check and start logging
logme "Temporary Admin Rights"
logme "Current user: $USERNAME"
logme "jamf binary location: $jamf_binary"

# Place launchd plist to call JSS policy to remove admin rights.

logme "Creating admin right removal LaunchDaemon"
echo "<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict>
	<key>Disabled</key>
	<true/>
	<key>Label</key> 
	<string>com.cultureamp.adminremove</string> 
	<key>ProgramArguments</key> 
	<array> 
		<string>$jamf_binary</string>
		<string>policy</string>
		<string>-event</string>
		<string>removeTempAdmin</string>
	</array>
	<key>StartInterval</key>
	<integer>1800</integer> 
</dict> 
</plist>" > $REMOVELD

# Set the permission on the file just made.
logme "Setting correct permissions on LaunchDaemon"
chown root:wheel $REMOVELD 2>&1 | tee -a ${LOG}
chmod 644 $REMOVELD 2>&1 | tee -a ${LOG}
defaults write $REMOVELD disabled -bool false 2>&1 | tee -a ${LOG}

# load the removal plist timer. 
logme "Enabling the removal LaunchDaemon"
launchctl load -w $REMOVELD 2>&1 | tee -a ${LOG}

# build log files in the logging location
logme "Username for admin rights logged"
echo $USERNAME >> "$TMPLOC"/userToRemove

# give current logged user admin rights
logme "$USERNAME granted temporary admin rights"
/usr/sbin/dseditgroup -o edit -a $USERNAME -t user admin 2>&1 | tee -a ${LOG}

#Function that generates dialog for capturing a reason for AOD rights
adminPrompt(){
    # $1 = window title
    # $2 = prompt text
    # $3 = default answer
    LOGO_ICNS="$(osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO_ICNS"'" as text')"
    osascript <<EOD
        tell application "System Events"
            with timeout of 8947848 seconds
                text returned of (display dialog "$2" default answer "$3" buttons {"OK"} default button 1 with title "$1" with icon file "$LOGO_ICNS")
            end timeout
        end tell
EOD
}

#Call the function and set the result as the variable
aodReason="$(adminPrompt 'Admin on Demand' 'Please enter the reason why you need Admin on Demand today' 'Reason')"

function post_reason () {
  MESSAGE="$1"
  URL=https://hooks.zapier.com/hooks/catch/31883/1t4jxk/
 
  curl -X POST --data "{\"text\": \"${MESSAGE}\", \"username\": \"${USERNAME}\"}" ${URL}
}

post_reason "$aodReason"
exit 0