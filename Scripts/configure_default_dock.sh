#!/bin/bash
# Author: James Smith - james@smithjw.me
# Version 1.1.0

dockutil="/usr/local/bin/dockutil"
log_prefix="CONFIGURE_DOCK"
logged_in_user=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
logged_in_user_uid=$(id -u "$logged_in_user")
logged_in_user_home=$(dscl . -read /users/"$logged_in_user" NFSHomeDirectory | cut -d " " -f 2)
dock_plist="${logged_in_user_home}/Library/Preferences/com.apple.dock.plist"
self_service_path=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist self_service_app_path)

echo_logger() {
    # echo_logger version 1.1
    log_folder="${log_folder:=/private/var/log}"
    /bin/mkdir -p "$log_folder"
    echo -e "$(date +'%Y-%m-%d %T%z') - ${log_prefix:+$log_prefix }${1}" | /usr/bin/tee -a "$log_folder/${log_name:=management.log}"
}

run_as_user() {
  if [ "$logged_in_user" != "loginwindow" ]; then
    launchctl asuser "$logged_in_user_uid" sudo -u "$logged_in_user" "$@"
  else
    echo_logger "No user logged in."
    exit 1
  fi
}

get_json_value() {
    JSON="$1" osascript -l 'JavaScript' \
        -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
        -e "JSON.parse(env).$2"
}

if [[ -f "$dockutil" ]]; then
    echo_logger "dockutil is installed"
else
    echo_logger "dockutil is not installed, downloading now"
    dockutil_latest=$( curl -sL https://api.github.com/repos/kcrawford/dockutil/releases/latest )
    dockutil_url=$(get_json_value "$dockutil_latest" 'assets[0].browser_download_url')
    curl -L --output "dockutil.pkg" --create-dirs --output-dir "/private/var/tmp" "$dockutil_url"
    echo_logger "Installing dockutil"
    installer -pkg "/private/var/tmp/dockutil.pkg" -target /
fi

dock_apps=(
    "$self_service_path"
    "/Applications/Privileges.app"
    "/Applications/Microsoft Edge.app"
    "/Applications/Slack.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Microsoft Outlook.app"
    "/System/Applications/System Preferences.app"
    "/System/Applications/System Settings.app"
)

echo_logger "Clearing out the existing Dock"
run_as_user $dockutil --remove all --no-restart "$dock_plist"

# Looping through the items in $dock_apps
echo_logger "Configuring the Dock"
for app in "${dock_apps[@]}"; do
    if [[ -f "$app/Contents/Info.plist" ]]; then
        run_as_user $dockutil --add "$app" --no-restart "$dock_plist"
    else
        echo_logger "Could not find $app"
    fi
done

echo_logger "Restarting the Dock"
killall Dock

exit 0
