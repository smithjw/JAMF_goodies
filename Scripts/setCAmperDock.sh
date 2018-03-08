#!/bin/bash

/usr/local/bin/dockutil --add /Applications/Self\ Service.app --position 1 --allhomes
/usr/local/bin/dockutil --add /Applications/Slack.app --position 2 --allhomes
/usr/local/bin/dockutil --add /Applications/zoom.us.app --position 3 --allhomes
/usr/local/bin/dockutil --add /Applications/Google\ Chrome.app --position 4 --allhomes

/usr/local/bin/dockutil --remove 'Siri' --allhomes
/usr/local/bin/dockutil --remove 'Launchpad' --allhomes
/usr/local/bin/dockutil --remove 'Safari' --allhomes
/usr/local/bin/dockutil --remove 'Mail' --allhomes
/usr/local/bin/dockutil --remove 'Contacts' --allhomes
/usr/local/bin/dockutil --remove 'Calendar' --allhomes
/usr/local/bin/dockutil --remove 'Reminders' --allhomes
/usr/local/bin/dockutil --remove 'Maps' --allhomes
/usr/local/bin/dockutil --remove 'Photos' --allhomes
/usr/local/bin/dockutil --remove 'Messages' --allhomes
/usr/local/bin/dockutil --remove 'FaceTime' --allhomes
/usr/local/bin/dockutil --remove 'iTunes' --allhomes
/usr/local/bin/dockutil --remove 'iBooks' --allhomes
