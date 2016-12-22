#!/bin/bash

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

app="/Applications/Avast.app/Contents/MacOS/Avast"

if [[ -e $app ]]; then
	echo "<result>Yes</result>"
else [[ ! -e $file ]]
	echo "<result>No</result>"
fi