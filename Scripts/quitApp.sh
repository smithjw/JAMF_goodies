#!/bin/bash

# Add if statement that looks to see if a given app (specified in $4) is currently running
# If app is running, present jamfHelper prompting to quit, then relaunch the app after updated
# If app isn't running, proceed with the update silently (no need to bother the user if they won't notice anything

HELPER=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/CAmperIT/enso@512.png -title "$1" -heading "Security Vulnerability" -alignHeading center -description "$1 needs to quit in order to be updated immediately. Please save any work that may be in progress." -button1 "Quit" -button2 "Cancel" -defaultButton 1 -cancelButton 2`

TRIGGER="update$1"
echo "$TRIGGER"

echo "jamf helper result was $HELPER";
	if [ "$HELPER" == "0" ]; then
		osascript -e 'quit app "'"$1"'"'
        /usr/local/bin/jamf policy -trigger $TRIGGER
        #Uncomment the following ling when this script is modified to first look if the App is running
        #osascript -e 'launch app "'"$4"'"'
        exit 0
   	else
        echo "user chose Cancel";   
    	exit 1
    fi