#!/bin/sh

USERNAME=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
LOGO_ICNS="/Library/Application Support/CAmperIT/enso@512.icns"

#Function that generates dialog for capturing a reason for AOD rights
adminPrompt(){
    # $1 = window title
    # $2 = prompt text
    # $3 = default answer
    LOGO_ICNS="$(osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO_ICNS"'" as text')"
    osascript <<EOD
        tell application "System Events"
            with timeout of 8947848 seconds
                text returned of (display dialog "$2" default answer "$3" buttons {"OK"} default button 1 with title "$1")
            end timeout
        end tell
EOD
}

#Call the function and set the result as the variable
aodReason="$(adminPrompt 'Admin on Demand' 'Please enter the reason why you need Admin on Demand today' 'Reason')"

function post_reason () {
  MESSAGE="$1"
  URL=https://hooks.zapier.com/hooks/catch/31883/1t4jxk/
 
  curl -X POST --data "{\"text\": \"${MESSAGE}\", \"username\": \"${USERNAME}\"}" ${URL}
}

post_reason "$aodReason"