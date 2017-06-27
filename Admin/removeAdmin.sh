#!/bin/bash
loggedInUser=`stat -f%Su /dev/console`
accountType=`dscl . -read /Users/"$loggedInUser" 2> /dev/null | grep UniqueID | cut -c 11-`

# change value of the "501" to 1000 if using mobile accounts. 

if [[ "$accountType" -gt "501" ]]; then

echo "demoting mobile account: $loggedInUser"
echo "UniqueID:$accountType"

sudo /usr/sbin/dseditgroup -o edit -d "$loggedInUser" -t user admin

else

echo "Must be local admin account: $loggedInUser"

fi
exit 0