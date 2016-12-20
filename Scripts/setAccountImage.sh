#!/bin/sh
PATH="/bin":"/usr/bin":"/sbin":"/usr/sbin"; export PATH

# variables (update with your own info)
ASSET=/Library/Application\ Support/CAmperIT/enso@512.png
MGMTPIC=/Library/User\ Pictures/enso.png
MGMTACCOUNT=_jamfmgmt


    # copy img to User Pictures
    cp "${ASSET}" "${MGMTPIC}"

    # set new image
    dscl . create "/Users/${MGMTACCOUNT}" Picture "${MGMTPIC}"

    # ensure permissions -- also probably not required, but...
    chown root:wheel "${MGMTPIC}"


exit 0