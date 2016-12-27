#!/bin/bash

# This script has been copied and slightly modified from https://github.com/rtrouton/rtrouton_scripts/blob/master/rtrouton_scripts/Casper_Scripts/self_service_os_install/sierra/self_service_sierra_os_install.sh

available_free_space=$(df -g / | tail -1 | awk '{print $4}')
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
needed_free_space="$4"
os_name="$5"
insufficient_free_space_for_install_dialog="Your SSD must have at least $needed_free_space gigabytes of free space available in order to install $os_name using Self Service. It only has $available_free_space gigabytes available. If you need assistance with freeing up space, please contact @it_support on Slack."
adequate_free_space_for_install_dialog="$os_name may take 30 minutes or more to install. Your Mac will restart immediately. Please be patient and do not restart your Mac mid-upgrade."

if [[ "$available_free_space" -lt "$needed_free_space" ]]; then
jamf displayMessage -message "$insufficient_free_space_for_install_dialog"
fi

if [[ "$available_free_space" -ge "$needed_free_space" ]]; then
echo "$available_free_space gigabytes found as free space on boot drive. Installing OS."

jamf displayMessage -message "$adequate_free_space_for_install_dialog"
jamf policy -trigger installSierra

fi

exit 0