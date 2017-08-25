#!/bin/bash

# Script to install Homebrew on a Mac.
# Author: richard at richard - purves dot com
# Version: 1.0 - 21st May 2017

# Set up variables and functions here
export consoleuser="$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"
export brandid="your id goes here"
export tn="/usr/local/bin/terminal-notifier.app/Contents/MacOS/terminal-notifier"
export title="Homebrew Installation"

# Logging stuff starts here
export LOGFOLDER="/private/var/log/"
export LOG=$LOGFOLDER"Homebrew.log"

if [ ! -d "$LOGFOLDER" ];
then
	mkdir $LOGFOLDER
fi

function logme()
{
# Check to see if function has been called correctly
	if [ -z "$1" ]
	then
		echo $( date )" - logme function call error: no text passed to function! Please recheck code!"
		echo $( date )" - logme function call error: no text passed to function! Please recheck code!" >> $LOG
		exit 1
	fi

# Log the passed details
	echo -e $( date )" - $1" >> $LOG
	echo -e $( date )" - $1"
}

function notify()
{
    OIFS=$IFS
    IFS=$'\n'
    su -l "$consoleuser" -c " "'"'$tn'"'" -sender "'"'$brandid'"'" -title "'"'$title'"'" -message "'"'$1'"'" "
	logme "$1"
	IFS=$OIFS
}

# Check and start logging - done twice for local log and for JAMF
logme "Homebrew Installation"

# Let's start here by caffinating the mac so it stays awake or bad things happen.
caffeinate -d -i -m -u &
caffeinatepid=$!
logme "Caffinating the mac under process id: $caffeinatepid"

# Have the xcode command line tools been installed?
notify "Checking for Xcode Command Line Tools installation"
check=$( pkgutil --pkgs | grep com.apple.pkg.CLTools_Executables | wc -l | awk '{ print $1 }' )

if [[ "$check" != 1 ]];
then
	notify "Installing Xcode Command Tools"
	# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
	touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
	clt=$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)
	softwareupdate -i "$clt"
	rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
	/usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi

# Is homebrew already installed?
which -s brew
if [[ $? = 1 ]];
then
    # Install Homebrew. This doesn't like being run as root so we must do this manually.
    notify "Downloading Homebrew"

	# Curl down the latest tarball and install to /usr/local
	curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /usr/local 2>&1 | tee -a ${LOG}

    # Manually make all the appropriate directories and set permissions
    mkdir -p /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    chown -R $consoleuser /usr/local
    chmod g+rwx /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
	chgrp admin /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var

	# Create a system wide cache folder
	mkdir -p /Library/Caches/Homebrew
	chmod g+rwx /Library/Caches/Homebrew
	chown $consoleuser /Library/Caches/Homebrew

	# Remove temporary folder
	rm -rf /usr/local/Homebrew

	# Install the MD5 checker or the recipes will fail
	notify "Installing md5sha1sum"
	su -l "$consoleuser" -c "/usr/local/bin/brew install md5sha1sum" 2>&1 | tee -a ${LOG}
	su -l "$consoleuser" -c "echo 'export PATH=/usr/local/opt/openssl/bin:\$PATH' >> /Users/$consoleuser/.bash_profile"
else
	# Run an update and quit
    notify "Updating Homebrew"
	su -l "$consoleuser" -c "/usr/local/bin/brew update" 2>&1 | tee -a ${LOG}
	exit 0
fi

# Make sure everything is up to date
notify "Updating Homebrew"
su -l "$consoleuser" -c "/usr/local/bin/brew update" 2>&1 | tee -a ${LOG}

# Notify user that all is completed
notify "Installation complete"

# No more caffeine please. I've a headache.
kill "$caffeinatepid"

exit 0
