#!/bin/bash

jamfbinary='/usr/bin/which jamf'


#######################################################################
# Gather Mac Information
#######################################################################

# Use serial number to determine the Mac model
model=$(curl http://support-sp.apple.com/sp/product?cc=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -c 9-` | sed 's|.*<configCode>\(.*\)</configCode>.*|\1|')

# Uses grep to look for all text before (
modelShort=$(echo "$model" | grep -o '^[^(]*')
echo "Model: $modelShort"

modelClean=${modelShort%?}

sn=$(ioreg -l | grep IOPlatformSerialNumber| cut -d'"' -f4 | grep -o '......$')
echo "Serial (short): $sn"

#######################################################################
# Work out the desired hostname (First Inital . Last Name - j.smith)
#######################################################################

# figure out the user
user=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#figure out the user's full name
name=$(finger "$user" | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )
echo "Name: $name"

# get first initial
finitial="$(echo "$name" | head -c 1)"

# get last name
lname="$(echo "$name" | cut -d \  -f 2)"

# add first and last together
hn=$finitial$lname-$modelClean-$sn

# clean up un to have all lower case
hostname=$(echo "$hn" | awk '{print tolower($0)}')
echo "Hostname: $hostname"

#######################################################################
# Functions
#######################################################################

sethostname() {
	/usr/local/bin/jamf setComputerName -name "$hostname"
	hostname -s "$hostname" 
}

########################################################################
# Script
########################################################################

sethostname

# # Make sure the Mac is managed and that the JSS can be reached
# /usr/local/bin/jamf manage

# # Apply any outstanding policies
# /usr/local/bin/jamf policy

# # Perform recon to ensure that the JSS is up-to-date
# /usr/local/bin/jamf recon