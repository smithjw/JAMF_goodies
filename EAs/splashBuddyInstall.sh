#!/bin/bash

# Specify location of done file
doneFile="/Users/Shared/.CasperSplashDone"

# If donefile does not exist, execute trigger
if [ ! -f "${doneFile}" ]; then

jamf policy -trigger runCS

fi

exit 0


