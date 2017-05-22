#!/bin/bash

jamfbinary=$(/usr/bin/which jamf)
loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
doneFile="/Users/Shared/.SplashBuddyDone"

echo "Installing Zoom"
${jamfbinary} policy -trigger "install-Zoom"

echo "Installing CAmper Assets"
${jamfbinary} policy -trigger "camperAssets"

echo "Installing Slack"
${jamfbinary} policy -trigger "install-Slack"

echo "Installing DockUtil"
${jamfbinary} policy -trigger "installDockUtil"

echo "Installing Google Chrome"
${jamfbinary} policy -trigger "install-Google Chrome"

echo "Re-enabling LittleSnitch where it had been disabled"
${jamfbinary} policy -trigger "enableLittleSnitch"

echo "Installing VPN Client"
${jamfbinary} policy -trigger "install-Viscosity"

echo "Installing Box Sync client"
${jamfbinary} policy -trigger "install-Box Sync"

echo "Setting up CAmper's Dock"
${jamfbinary} policy -trigger "setDock"

echo "Pulling down FileVault 2 configuration"
${jamfbinary} policy -trigger "requireFV2"

echo "Updating Inventory"
${jamfbinary} policy -trigger "updateInventory"

echo "Creating done file"
touch "$doneFile"

echo "Quitting SplashBuddy"
osascript -e 'quit app "SplashBuddy"'

echo "Unloading and removing Splashbuddy LaunchDaemon"
launchctl unload /Library/LaunchDaemons/io.fti.splashbuddy.launch.plist
rm -f /Library/LaunchDaemons/io.fti.splashbuddy.launch.plist

echo "Deleting SplashBuddy"
rm -rf "/Library/Application Support/SplashBuddy"

echo "Logging user out to force FileVault Encryption"
kill -9 `pgrep loginwindow`
