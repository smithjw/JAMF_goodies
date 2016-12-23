#!/bin/bash

file="/Library/Application Support/CAmperIT/enso@512.png"

if [[ -e $file ]]; then
    echo "<result>Yes</result>"
else [[ ! -e $file ]]
    echo "<result>No</result>"
fi
