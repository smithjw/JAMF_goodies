#!/bin/bash

# Script Variables
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
profileDir="/Users/$loggedInUser/Library/Application Support/Google/Chrome/Testing"

# Script Content
mkdir -p "$profileDir"
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="$profileDir" --profile-directory="$profileDir"
#open -a "Google Chrome" 'https://chrome.google.com/webstore/detail/tunnelbear-vpn/omdakjcmkglenbhjadbccaookpfjihpa'
