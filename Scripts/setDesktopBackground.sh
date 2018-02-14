#!/bin/bash

# Create an array with the contents of the CA Wallpapers filder
wallpapers=(/Library/Desktop\ Pictures/CA\ Wallpapers/*)
# Seed a random number
RANDOM=$$$(date +%s)

# Select one of the wallpapers from the array
selectedWallpaper=${wallpapers[$RANDOM % ${#wallpapers[@]} ]}

echo "${selectedWallpaper}"

# Set this wallpaper during enrolment
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"$selectedWallpaper"'"'

exit 0
