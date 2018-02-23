#!/bin/bash
# This script is used to open a number of useful links while CAmper's are proceeding through their Onboarding

open -a "Google Chrome" 'https://cultureamp.okta.com'
open -a "Google Chrome" 'https://google.com/mail'
open -a "Google Chrome" 'https://google.com/calendar'
open -a "Google Chrome" 'https://cultureamp.bamboohr.com/'
open -a "Google Chrome" 'https://app.greenhouse.io/users/sign_in'
open -a "Google Chrome" 'https://cultureamp.atlassian.net/wiki'

osascript -e 'tell application "System Events" to keystroke "1" using {command down}'

exit 0
