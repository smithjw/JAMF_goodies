#!/bin/bash

mkdir -p Signed

for profile in *.mobileconfig
do
	#s=${profile##*/}
	#outName=${profile}
	#outName="Signed.mobileconfig"
	/usr/bin/security cms -S -N "Developer ID Installer: James Smith (26TRL2HGJZ)" -i "$profile" -o "Signed/$profile"
done
