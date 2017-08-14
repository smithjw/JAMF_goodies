#!/bin/bash

# This is the removal script for the tempadmin.sh script. 
# It will remove the user from the admin group. Then it will disable the plist that calls this script.  

# Original script by Andrina Kelly : https://github.com/andrina/JNUC2013/blob/master/Users%20Do%20Your%20Job/MakeMeAdmin/
# Updated by Richard Purves - 13th February 2017 - richard at richard - purves dot com

# Define variables and logging here
COMPANY="com.cultureamp.adminremove"
REMOVELD="/Library/LaunchDaemons/$COMPANY.plist"
TMPLOC="/usr/local/cultureamp/misc"
LOGFOLDER="/private/var/log/cultureamp"
LOG=$LOGFOLDER"TempAdminRightsRemoval.log"

if [ ! -d "$LOGFOLDER" ];
then
	mkdir $LOGFOLDER
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

if [[ -f "$TMPLOC"/userToRemove ]]; then
	USERNAME=$( cat "$TMPLOC"/userToRemove )
	logme "Removing $USERNAME from admin group"
	/usr/sbin/dseditgroup -o edit -d $USERNAME -t user admin 2>&1 | tee -a ${LOG}
	rm -f "$TMPLOC"/userToRemove
else
	defaults write "$REMOVELD" disabled -bool true
	logme "Unloading and deleting admin removal LaunchDaemon"
	launchctl unload -w "$REMOVELD"
	rm -f /Library/LaunchDaemons/com.cultureamp.adminremove.plist
fi
exit 0