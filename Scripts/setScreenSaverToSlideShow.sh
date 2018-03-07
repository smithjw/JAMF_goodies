#!/bin/bash

# Sets your Screen Saver
# Tested on 10.12+

# User defined variables
testPhotosLocation="/Users/smithjw/Desktop/WHM"
photosLocation=""
#saverName="Aerial"

# Don't edit below here
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

su -l $loggedInUser -c "defaults write /Users/$loggedInUser/Library/Preferences/ByHost/com.apple.screensaver.plist moduleDict -dict moduleName \"iLifeSlideshow\" path \"/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/iLifeSlideshows.saver\" type 0"
su -l $loggedInUser -c "defaults write com.apple.ScreenSaverPhotoChooser LastViewedPhotoPath \"\""
su -l $loggedInUser -c "defaults write com.apple.ScreenSaverPhotoChooser SelectedFolderPath '$testPhotosLocation'"
su -l $loggedInUser -c "defaults write com.apple.ScreenSaverPhotoChooser SelectedSource -int 3"
su -l $loggedInUser -c "defaults write com.apple.ScreenSaverPhotoChooser ShufflesPhotos -bool true"
su -l $loggedInUser -c "defaults write com.apple.ScreenSaverPhotoChooser LastViewedPhotoPath \"\""
su -l $loggedInUser -c "defaults write /Users/$loggedInUser/Library/Preferences/ByHost/com.apple.screensaver.plist idleTime 300"

su -l $loggedInUser -c "defaults write com.apple.ScreenSaver.iLifeSlideShows styleKey \"Classic\""

killall cfprefsd

exit 0
