#!/bin/bash
# shellcheck disable=SC2046

###
#
#            Name:  enrolment.sh
#     Description:  Enrolment script used to setup Macs for use
#            Note:
#		   Author:  James Smith <james@smithjw.me>
#         Created:  2017-05-22
#   Last Modified:  2018-02-23
#         Version:  1.0
#
###

jamfbinary=$(/usr/bin/which jamf)
doneFile="/Users/Shared/.SplashBuddyDone"

echo "Drinking some Red Bull so the Mac doesn't fall asleep"
caffeinate -d -i -m -u &
caffeinatepid=$!

echo "Installing Slack"
${jamfbinary} policy -event "install-Slack"

echo "Installing CAmper Assets"
${jamfbinary} policy -event "camperAssets"

echo "Installing Zoom"
${jamfbinary} policy -event "install-Zoom"

echo "Installing DockUtil"
${jamfbinary} policy -event "installDockUtil"

echo "Installing Google Chrome"
${jamfbinary} policy -event "install-Google Chrome"

echo "Installing VPN Client"
${jamfbinary} policy -event "install-Viscosity"

echo "Installing Box Sync client"
${jamfbinary} policy -event "install-Box Sync"

echo "Setting up CAmper's Dock"
${jamfbinary} policy -event "setDock"

echo "Pulling down FileVault 2 configuration"
${jamfbinary} policy -event "requireFV2"

echo "Creating done file"
touch "$doneFile"

echo "Updating Inventory"
${jamfbinary} policy -event "updateInventory"

echo "Quitting SplashBuddy"
osascript -e 'quit app "SplashBuddy"'

echo "Unloading and removing Splashbuddy LaunchDaemon"
launchctl unload /Library/LaunchDaemons/io.fti.splashbuddy.launch.plist
rm -f /Library/LaunchDaemons/io.fti.splashbuddy.launch.plist

echo "Deleting SplashBuddy"
rm -rf "/Library/Application Support/SplashBuddy"

echo "Drank waaaayyyyy too much Red Bull"
kill "$caffeinatepid"

echo "Logging user out to force FileVault encryption"
kill -9 `pgrep loginwindow`
