#!/bin/bash

mkdir -p Signed

for profile in *.mobileconfig
do
	#s=${profile##*/}
	#outName=${profile}
	#outName="Signed.mobileconfig"
	/usr/bin/security cms -S -N "Mac Developer: James Smith (8964FZF9BE)" -i "$profile" -o "Signed/$profile"
done
