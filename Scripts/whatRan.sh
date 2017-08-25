#!/bin/bash

# Makes CAmper IT dir if it doesn't already exist; it really sure but better safe than sorry
mkdir -p /Library/Application\ Support/CAmperIT

# Reads jamf.log
# grep -v excludes any lines with "What is JAMF doing" or "Update Inventory" in it
# grep "" finds lines with relevant information
# sed formats it nicely
# then outputs to a file
/bin/cat /var/log/jamf.log | grep -v "What is JAMF doing" | grep -v "Update Inventory" | grep "Executing\|Installing\|Updating\|Adding\|Existing\|Removing\|Deleting" | sed s/jamf\[[0-9]*\]://g 2>&1 > /Library/Application\ Support/CAmperIT/whatRan.txt

exit 0
