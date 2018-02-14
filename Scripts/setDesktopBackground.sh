#!/bin/bash

# Create an empty array
wallpapers=(/Library/Desktop\ Pictures/CA\ Wallpapers/*)
RANDOM=$$$(date +%s)

selectedWallpaper=${wallpapers[$RANDOM % ${#wallpapers[@]} ]}

echo "${selectedWallpaper}"

osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"$selectedWallpaper"'"'

exit 0
