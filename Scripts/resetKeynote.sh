#!/bin/bash

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
keynoteFolder="/Users/$loggedInUser/Library/Containers/"

# Create an archive of the old folder with the following switches and places it on the User's Desktop
#
# -r   recurse into directories
# -y   store symbolic links as the link instead of the referenced file
# -m   move into zipfile (delete OS files)

cd $keynoteFolder || exit
zip -ry "/Users/$loggedInUser/Desktop/keynoteContainer.zip" com.apple.iWork.Keynote

exit 0
