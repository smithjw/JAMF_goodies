#!/bin/bash
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
sublimeLicense="/Users/"$loggedInUser"/Library/Application Support/Sublime Text 3/Local/License.sublime_license"


echo "$4" > "$sublimeLicense"

exit 0
