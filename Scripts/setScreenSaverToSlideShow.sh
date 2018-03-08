#!/bin/bash

# Sets your Screen Saver to a Photo Slide Show
# Tested on 10.13+

# User defined variables
photosLocation="/Users/Shared/WHM"

# Don't edit below here
pb="/usr/libexec/PlistBuddy"
uuid=`system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }'`
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
shplist="/Users/'$loggedInUser'/Library/Preferences/ByHost/fr.whitebox.SaveHollywood.'$uuid'.plist"

# Write settings for the correct screen saver
# This sets the screensaver to SaveHollywood (http://s.sudre.free.fr/Software/SaveHollywood/about.html)
# and then sets a timeout of 3 mins for it to start
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName \"SaveHollywood\" path \"/Library/Screen Savers/SaveHollywood.saver\" type 0"
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver idleTime 300"
su -l $loggedInUser -c "defaults -currentHost write com.apple.screensaver CleanExit -string \"YES\""

# Settings specific to SaveHollywood
# Firstly, let's add some of the settings
su -l $loggedInUser -c "$pb -c \"Clear\" $shplist"
su -l $loggedInUser -c "$pb -c \"Add :assets.randomOrder bool true\" $shplist"
su -l $loggedInUser -c "$pb -c \"Add :assets.startWhereLeftOff bool true\" $shplist"
su -l $loggedInUser -c "$pb -c \"Add :movie.volume.mode integer 1\" $shplist"

# Now we'll create the Array for the video files
su -l $loggedInUser -c "$pb -c \"Add :assets.library array\" $shplist"

# And finally, we'll loop through the folder where the videos are stored and add them into the plist
for file in $photosLocation/*.mp4; do
    echo "$file"
    su -l $loggedInUser -c "$pb -c \"Add :assets.library: string $file\" $shplist"
done

exit 0
