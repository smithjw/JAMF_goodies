#!/bin/bash

sleep 10
echo "Quitting SplashBuddy"
osascript -e 'quit app "SplashBuddy"'

echo "Unloading and removing Splashbuddy LaunchDaemon"
launchctl unload /Library/LaunchDaemons/io.fti.splashbuddy.launch.plist
rm -f /Library/LaunchDaemons/io.fti.splashbuddy.launch.plist

echo "Deleting SplashBuddy"
rm -rf /Library/SplashBuddy

echo "Logging user out to force FileVault Encryption"
osascript -e 'tell application "System Events" to keystroke "q" using {command down, option down, shift down}'