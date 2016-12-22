#!/bin/bash

TIMESTAMP=`date +%s`
exec >/tmp/avastuninstall-"$TIMESTAMP"-$$.log 2>&1
set -x
shopt -s nullglob
echo "PID=$$"

# If this file would in any case be executed, it would delete all directories in system root
rm -rf "/Applications/avast!.app/Contents/MacOS/install.sh"

AVAST_DIR="/Library/Application Support/Avast"
COMPONENTS_DIR="$AVAST_DIR/components"
INSTALL_SCRIPTS_DIR="$AVAST_DIR/hub"

# Setup local variables
MODULES_DIR="$INSTALL_SCRIPTS_DIR/modules"
AVAST_LOCK_DIR="/tmp/com.avast.lockdir"
AVAST_LOCK_CHECK_DELAY=1
CIQ_BINARY="$COMPONENTS_DIR/ciq/com.avast.ciqstatsend"
MACOSXVERSION=`sw_vers -productVersion | cut -d\. -f2`

ACTIVE_UIDS=`ps -A -o uid,comm | grep '/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock' | awk '{print $1}'`

EXIT_CODE=0
REBOOT_NECESSARY_EXIT_CODE=255



#==== FUNCTIONS ===========================

#mutual exclusion - wait for lock
#note -after reboot, the directory is always empty
acquireLock()
{
    AVAST_LOCK_ACQUIRED=0
    COUNTER=0
    while [ "$AVAST_LOCK_ACQUIRED" -lt 1 ]
    do
        if mkdir "$AVAST_LOCK_DIR"; then
            AVAST_LOCK_ACQUIRED=1
            touch "$AVAST_LOCK_DIR/avastuninstall"
        else
            sleep "$AVAST_LOCK_CHECK_DELAY"
            COUNTER=$(($COUNTER+1))
            if [ $COUNTER -eq 30 ]; then
                break
            fi
        fi
    done
}

safeExit()
{
    if [ -d "$AVAST_LOCK_DIR" ]; then
        rm -rf "$AVAST_LOCK_DIR"
    fi

    # If launched with com.avast.uninstall.plist, launchd will kill uninstall.sh
    (
        launchctl remove "com.avast.uninstall"
        rm -f "/Library/LaunchDaemons/com.avast.uninstall.plist"
        rm -rf "$AVAST_DIR"
        killall -9 avast\!
        killall -9 "Avast"
        rm -rf "/Applications/avast!.app"
        rm -rf "/Applications/Avast.app"
    ) &

    exit $1
}

launchModulesRev()
{
    ARG="$1"
    printf "\n=== %s ===\n" "$ARG"
    printf "launchModulesRev start time: %s\n" `date +%s`

    MODULES_ARR=( "$MODULES_DIR/"* )
    for (( idx=${#MODULES_ARR[@]}-1 ; idx>=0 ; idx-- )) ; do
        MOD=${MODULES_ARR[idx]}
        if [ -x "$MOD" ]; then
            printf "\n*** Module %s at %s ***\n\n" `basename "$MOD"` `date +%s`
            "$MOD" "$ARG" 2>&1
            RET=$?
            if [ $RET != 0 ]; then
                printf "Failed: %d\n" $RET
                EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
            fi
        fi
    done
    printf "launchModulesRev end time: %s\n" `date +%s`
}

launchAsUser()
{
    user=$1
    shift

    dock_pid=`ps -u "$user" -o pid,command | sed 's/  */ /g' | sed 's/^ *//' | grep '/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock' | grep -vw "grep" | cut -f1 -d' '`
    if [ -z "$dock_pid" ]; then
        return
    fi

    if [ "$MACOSXVERSION" -lt 11 ]; then
        launchctl bsexec "$dock_pid" sudo -Hu "$user" "$@"
    else
        sudo -Hu "$user" "$@"
    fi
}

waitUntilDone()
{
    for i in {1..30}; do
        sleep 0.5
        [ `ps -ax | grep -vw grep | grep "$1" | wc -l` -eq 0 ] && break
    done
    [ `ps -ax | grep -vw grep | grep "$1" | wc -l` -gt 0 ] && EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
}

ciqSendStats()
{
    if [ -x "$CIQ_BINARY" ]; then
        NEED_REBOOT="no"
        if [ $EXIT_CODE -ne 0 ]; then
            NEED_REBOOT="yes"
        fi

        "$CIQ_BINARY" "$@" "--prg-version=$VERSION" "--need-reboot=$NEED_REBOOT" >/dev/null 2>&1 &
    fi
}

readConf()
{
    CONF_FILE="$1"
    KEY="$2"
    DEFAULT_VALUE="$3"

    if [ ! -f "$CONF_FILE" ]; then
        echo "$DEFAULT_VALUE"
    fi

    VALUE=`cat "$CONF_FILE" | grep -i "^${KEY} *=" | tail -1 | cut -d= -f2`
    if [ -z VALUE ]; then
        echo "$DEFAULT_VALUE"
    fi

    echo "$VALUE" | sed 's/ *\(.*\) */\1/' | sed 's/"\(.*\)"/\1/'
}

#==========================================

# Verify environment conditions
if [ `id -u` -ne 0 ]; then
    echo "Script must be executed with root priviledges"
    exit 1
fi

# Stop update
launchctl unload "/Library/LaunchDaemons/com.avast.update.plist"
UPDATE_PID=`ps -ax | grep -v "grep" | grep "$COMPONENTS_DIR/update/update.sh" | awk '{print $1}'`
if [ ! -z "$UPDATE_PID" ]; then
    kill $UPDATE_PID
fi

# Uninstall per-user staff.
if [ -n "$ACTIVE_UIDS" ]; then
    for uid in $ACTIVE_UIDS; do
        user=`id -un ${uid}`
        if [ -S "$AVAST_DIR/run/update/${uid}.sock" ]; then
            echo "stop" | nc -U "$AVAST_DIR/run/update/${uid}.sock"
            echo "uninstall" | nc -U "$AVAST_DIR/run/update/${uid}.sock"
        elif [ -S `eval echo ~$user`"/Library/Application Support/Avast/update-agent.sock" ]; then
            # Older avast version.
            echo "stop" | nc -U `eval echo ~$user`"/Library/Application Support/Avast/update-agent.sock"
            echo "uninstall" | nc -U `eval echo ~$user`"/Library/Application Support/Avast/update-agent.sock"
        else
            EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
        fi
    done
    sleep 1.5
    for uid in $ACTIVE_UIDS; do
        user=`id -un ${uid}`
        if [ -d `eval echo ~$user`"/Library/Application Support/Avast" ]; then
            sudo -Hu "$user" "$AVAST_DIR/hub/userinit.sh" "uninstall"
            EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE

            APP_TRASH_DIR=`eval echo ~$user`"/.Trash/Avast.app"
            [ -d "$APP_TRASH_DIR" ] && rm -r "$APP_TRASH_DIR"
        fi
    done
fi

# Acuire lock
trap safeExit EXIT SIGTERM
acquireLock


# CIQ
if [ -f "$AVAST_DIR/version.tag" ]; then
    VERSION=`cat "$AVAST_DIR/version.tag"`
    ciqSendStats uninstall "--from=$VERSION"
fi

# Unpair account
ACCOUNT_SYNC="$COMPONENTS_DIR/account/com.avast.account-sync"
ACCOUNT_CONNECT="$COMPONENTS_DIR/account/com.avast.account-connect"
if [ -x "$ACCOUNT_SYNC"  -a  -x "$ACCOUNT_CONNECT" ]; then
    AUID=`readConf "$AVAST_DIR/config/com.avast.registration.conf" AUID ""`
    if [ -n "$AUID" ]; then
        "$ACCOUNT_SYNC" --event=disconnect
        "$ACCOUNT_CONNECT" unpair --auid="$AUID"
    fi
fi


# Uninstall modules
if [ -d "$MODULES_DIR" ]; then
    set +x

    # Stop system modules
    launchModulesRev "stop"

    # Uninstall system modules
    launchModulesRev "uninstall"

    set -x
else
    EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
fi

pkgutil --forget "com.avast.avast"
pkgutil --forget "com.avast.appsupport"

# Check that no avast kexts are loaded
if [ `kextstat | grep com.avast | wc -l` -ne 0 ]; then
    EXIT_CODE=$REBOOT_NECESSARY_EXIT_CODE
fi

# Store
for STORE_PRODUCT in "$@"; do
    "${AVAST_DIR}/store/store.sh" "uninstall" "$STORE_PRODUCT"
done


# Final cleaup of everything that needs root permissions
# Not always the modules directory is available, clean as much as possible
# It must uninstall also Avast v.7 where /Library/Application Support/Avast/launch/LaunchDaemons was not present
# /Library/LaunchDaemons/com.avast.uninstall.plist must not be unloaded at this moment
launchctl unload "/Library/LaunchDaemons/com.avast.init.plist"
if [ -d "$AVAST_DIR" ]; then
    for plist in "$AVAST_DIR/launch/LaunchDaemons/"*; do
        bname=`basename "$plist"`
        [ -f "/Library/LaunchDaemons/${bname}" ] && rm "/Library/LaunchDaemons/${bname}"
    done

    for plist in "$AVAST_DIR/launch/LaunchAgents/"*; do
        bname=`basename "$plist"`
        [ -f "/Library/LaunchAgents/${bname}" ] && rm "/Library/LaunchAgents/${bname}"
    done
fi
rm -f "/Library/LaunchDaemons/com.avast.init.plist"
rm -f "/Library/LaunchDaemons/com.avast.update.plist"
rm -f "/Library/LaunchAgents/com.avast.userinit.plist"
rm -f "/Library/LaunchAgents/com.avast.useruninstall.plist"
rm -f "/Library/LaunchAgents/com.avast.update-agent.plist"
rm -rf "/Library/PreferencePanes/Avast.prefPane"
rm -rf "/tmp/avastUserUninstallNotif"

# Legacy plists from a previous version
rm -f "/Library/LaunchDaemons/com.avast.account.plist"
rm -f "/Library/LaunchDaemons/com.avast.crashreport.plist"
rm -f "/Library/LaunchDaemons/com.avast.daemon.plist"
rm -f "/Library/LaunchDaemons/com.avast.fileshield.plist"
rm -f "/Library/LaunchDaemons/com.avast.kexts.plist"
rm -f "/Library/LaunchDaemons/com.avast.proxy.plist"
rm -f "/Library/LaunchDaemons/com.avast.regapp.plist"
rm -f "/Library/LaunchAgents/com.avast.helper.plist"
rm -f "/Library/LaunchAgents/com.avast.install.plist"

# Release lock
exit $EXIT_CODE
