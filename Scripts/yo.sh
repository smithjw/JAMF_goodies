#!/bin/bash

yoBinary="/Applications/Utilities/yo.app/Contents/MacOS/yo"
title=$(printf %q "$4")
info=$(printf %q "$5")
otherButton=$(printf %q "$6")
actionButton=$(printf %q "$7")
actionPath=$(printf %q "$8")
scriptURL=$(printf %q "${9}")
iconPath=$(printf %q "${10}")
iconURL=$(printf %q "${11}")


grabConsoleUserAndHome(){
	currentUser=$(stat -f %Su "/dev/console")
	homeFolder=$(dscl . read "/Users/$currentUser" NFSHomeDirectory | cut -d: -f 2 | sed 's/^ *//'| tr -d '\n')
	case "$homeFolder" in  
		*\ * )
		homeFolder=$(printf %q "$homeFolder")
		;;
		*)
		;;
	esac
}

downloadIcon()
{
	iconURLFile="${iconURL##*/}"
	extension="${iconURLFile##*.}"
	iconLocal="/tmp/icon."$extension""
	rm -f "$iconLocal"
	filerConnection=$(/usr/bin/curl -L -s -o /dev/null --silent --head --write-out '%{http_code}' "http://google.com/" --location-trusted -X GET)
	if [[ "$filerConnection" = 200 ]]; then
		echo "Downloading Icon..."
		/usr/bin/curl -L "$iconURL" -o "$iconLocal" --location-trusted
	else
		echo "Unable to download icon. Skipping..."
	fi
}

downloadScript()
{
	scriptLocal="/tmp/script.sh"
	rm -f "$scriptLocal"
	filerConnection=$(/usr/bin/curl -L -s -o /dev/null --silent --head --write-out '%{http_code}' "http://google.com/" --location-trusted -X GET)
	if [[ "$filerConnection" = 200 ]]; then
		echo "Downloading Script..."
		/usr/bin/curl -L "$scriptURL" -o "$scriptLocal" --location-trusted
		chmod +x "$scriptLocal"
	else
		echo "Unable to download script. Exiting..."
		exit 1
	fi
}

grabConsoleUserAndHome

if [[ "$currentUser" == "root" ]]; then
	exit 0
fi

if [[ "$iconPath" != "''" ]]; then
	iconLocal=$iconPath
fi

if [[ "$iconURL" != "''" ]]; then
	downloadIcon
fi

if [[ "$scriptURL" != "''" ]]; then
	downloadScript
fi

IFS=$'\t\n'
if [[ -z $otherButton ]]
then
	if [[ -e " $iconLocal" ]] && [[ -e "$scriptLocal" ]]
	then
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --action-btn "$actionButton" --icon " $iconLocal" --bash-action "$scriptLocal" -p"      
	elif [[ -e " $iconLocal" ]]
	then
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --action-btn "$actionButton" --action-path "$actionPath" --icon " $iconLocal" -p"   
	elif [[ -e "$scriptLocal" ]]
	then
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --action-btn "$actionButton" --bash-action "$scriptLocal" -p"
	else
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --action-btn "$actionButton" --action-path "$actionPath" -p"
	fi
else
	if [[ -e " $iconLocal" ]] && [[ -e "$scriptLocal" ]]
	then
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --other-btn "$otherButton" --action-btn "$actionButton" --icon " $iconLocal" --bash-action "$scriptLocal" -p"     
	elif [[ -e " $iconLocal" ]]
	then
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --other-btn "$otherButton" --action-btn "$actionButton" --action-path "$actionPath" --icon " $iconLocal" -p"  
	elif [[ -e "$scriptLocal" ]]
	then
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --other-btn "$otherButton" --action-btn "$actionButton" --bash-action "$scriptLocal" -p"
	else
		su - "$currentUser" -c "$yoBinary --title "$title" --info "$info" --other-btn "$otherButton" --action-btn "$actionButton" --action-path "$actionPath" -p"
	fi
fi

unset IFS

exit 0