#!/bin/bash
#
# This script estimates the build date of a Mac and presents a dialog 
# to a user presenting detailing an approx date for replacement
#
# Warranty estimator via https://github.com/chilcote/warranty
# Initial script via Adam Codega https://github.com/acodega/jamfpro/blob/master/laptopReplacer.sh
#

jamfHelper="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
creation=`/Library/Application\ Support/CAmperIT/warranty | awk '/Manufactured/ {print $3}'`
destruction=`date -j -f %Y-%m-%d -v+2y $creation +"%b %d, %Y"`

$jamfHelper ok-msgbox --no-cancel --title "Mac Upgrade Check" --text "Your Mac's warranty expires around $destruction" --informative-text "You are due for a new Mac around that date 😄" --icon computer &> /dev/null

exit 0
