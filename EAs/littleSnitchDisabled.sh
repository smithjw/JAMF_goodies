#!/bin/bash

file="/Library/Little Snitch.backup"

if [[ -e $file ]]; then
    echo "<result>Yes</result>"
else [[ ! -e $file ]]
    echo "<result>No</result>"
fi
