#!/bin/bash
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
selection=$("$jamfHelper" -windowType "utility" -button1 'OK' -button2 'Contact IT' -defaultButton 1 -timeout 30)

echo "Button clicked was: $selection"

	if [[ "$selection" == "2" ]]; then
		open "slack://channel?id=C07LEFT9N&team=T02S77EMD"
	fi
