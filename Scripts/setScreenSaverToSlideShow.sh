#!/bin/bash

# Sets your Screen Saver to a Photo Slide Show
# Tested on 10.12+

# User defined variables
photosLocation="/Users/Shared/WHM/"

# Don't edit below here
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName \"iLifeSlideshow\" path \"/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/iLifeSlideshows.saver\" type 0"
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver idleTime 300"
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver CleanExit -string \"YES\""
su -l $loggedInUser -c "defaults -currentHost write com.apple.ScreenSaverPhotoChooser LastViewedPhotoPath \"\""
su -l $loggedInUser -c "defaults -currentHost write com.apple.ScreenSaverPhotoChooser SelectedFolderPath '$photosLocation'"
su -l $loggedInUser -c "defaults -currentHost write com.apple.ScreenSaverPhotoChooser SelectedSource -int 10"
su -l $loggedInUser -c "defaults -currentHost write com.apple.ScreenSaverPhotoChooser ShufflesPhotos -bool true"
su -l $loggedInUser -c "defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows styleKey \"Classic\""

killall cfprefsd

exit 0
