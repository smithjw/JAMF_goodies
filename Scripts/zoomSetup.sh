#!/bin/bash

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
echo "$loggedInUser"
PLIST="/Users/$loggedInUser/Library/Preferences/us.zoom.config.plist"

echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>nogoogle</key>
	<string>1</string>
	<key>nofacebook</key>
	<string>1</string>
	<key>ZDisableVideo</key>
	<false/>
	<key>ZAutoJoinVoip</key>
	<true/>
	<key>ZAutoSSOLogin</key>
	<true/>
	<key>ZAutoFullScreenWhenViewShare</key>
	<true/>
	<key>ZAutoFitWhenViewShare</key>
	<true/>
	<key>ZUse720PByDefault</key>
	<false/>
	<key>ZRemoteControlAllApp</key>
	<true/>
	<key>ZHideNoVideoUser</key>
	<true/>
</dict>
</plist>" > $PLIST
