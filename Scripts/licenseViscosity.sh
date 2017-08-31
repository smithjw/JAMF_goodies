#!/bin/sh

# Get the Username of the currently logged user
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

su -l $loggedInUser -c "defaults write /Users/$loggedInUser/Library/Preferences/com.viscosityvpn.Viscosity.plist License -string "$4" | killall cfprefsd"
