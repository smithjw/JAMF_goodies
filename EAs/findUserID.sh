#!/bin/bash
adminID=`dscl . -read /Users/NAME_OF_MANAGEMENT_ACCOUNT UniqueID | awk '{print $2}'`
echo "<result>$adminID</result>"
