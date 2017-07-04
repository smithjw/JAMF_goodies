#!/bin/bash
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
sublimeLicense="/Users/"$loggedInUser"/Library/Application Support/Sublime Text 3/Local/License.sublime_license"


echo "----- BEGIN LICENSE -----
Insert License Here
------ END LICENSE ------" > "$sublimeLicense"

exit 0
