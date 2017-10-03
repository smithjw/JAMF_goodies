#!/bin/bash

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
