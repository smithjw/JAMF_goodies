#!/bin/bash

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

app="/Applications/Sublime Text.app/Contents/MacOS/Sublime Text"

file="/Users/"$loggedInUser"/Library/Application Support/Sublime Text 3/Local/License.sublime_license"

if [[ -e $app ]]; then
	if [[ -e $file ]]; then
		echo "<result>Found</result>"
	else [[ ! -e $file ]]
		echo "<result>Not Found</result>"
	fi
else [[ ! -e $file ]]
	echo "<result>Sublime Text Not Installed</result>"
fi