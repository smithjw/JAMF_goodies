#!/bin/bash

# Sets your Screen Saver
# Tested on 10.12+

# User defined variables
saverLocation="/Library/Screen Savers/Aerial.saver"
saverName="Aerial"

# Don't edit below here
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

su -l $loggedInUser -c "defaults write /Users/$loggedInUser/Library/Preferences/ByHost/com.apple.screensaver.plist moduleDict -dict path -string '$saverLocation' moduleName -string '$saverName'"
su -l $loggedInUser -c "defaults write /Users/$loggedInUser/Library/Preferences/ByHost/com.apple.screensaver.plist idleTime 3600"
exit 0
