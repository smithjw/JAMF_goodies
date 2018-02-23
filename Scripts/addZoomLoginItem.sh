#!/bin/bash

###
#
#            Name:  addZoomLoginItem.sh
#     Description:  This script adds ZoomPresence to the login items.
#					Best used when not installed by the native ZoomPresence installer
#            Note:
#		   Author:  James Smith <james@smithjw.me> 
#         Created:  2017-10-03
#   Last Modified:  2018-02-23
#         Version:  1.0
#
###

mkdir -p /Users/ca_room/Library/LaunchAgents

echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.cultureamp.zoomrooms</string>
		<key>Program</key>
		<string>/Applications/ZoomPresence.app</string>
		<key>RunAtLoad</key>
		<true/>
	</dict>
</plist>" > /Users/ca_room/Library/LaunchAgents/com.cultureamp.zoomrooms.plist

launchctl load /Users/ca_room/Library/LaunchAgents/com.cultureamp.zoomrooms.plist
exit 0
