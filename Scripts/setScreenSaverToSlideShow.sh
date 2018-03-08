#!/bin/bash

# Sets your Screen Saver to a Photo Slide Show
# Tested on 10.12+

# User defined variables

photosLocation="/Users/Shared/WHM/"

# Don't edit below here
pb="/usr/libexec/PlistBuddy -c"
uuid="system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }'"
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
shplist="/Users/$loggedInUser/Library/Preferences/ByHost/fr.whitebox.SaveHollywood.$uuid.plist"

# Write settings for the correct screen saver
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName \"SaveHollywood\" path \"/Library/Screen Savers/SaveHollywood.saver\" type 0"
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver idleTime 300"
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver CleanExit -string \"YES\""

# Settings specific to SaveHollywood


su -l $loggedInUser -c "$pb \"Add :assets.library: string /Users/Shared/WHM/12.mp4\"" $shplist


killall cfprefsd

exit 0
