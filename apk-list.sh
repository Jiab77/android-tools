#!/usr/bin/env bash

# Basic Android APK files list script
# Made by Jiab77 / 2023
#
# References:
# - https://gist.github.com/AnatomicJC/e773dd55ae60ab0b2d6dd2351eb977c1
#
# Version 0.0.1

# Options
set +o xtrace

# Config
DUMP_TYPE=$1
DUMP_LOG="$(basename "$0" | sed -e 's/.sh//i').errors.log"

# Functions
function list_devices() {
    echo -e "\nListing attached devices...\n"
    adb devices -l | grep -vi "list"
}
function list_apps() {
    local INDEX=1
    echo -e "\nListing installed applications...\n"
    for APP in $(adb shell pm list packages "$DUMP_ARG" -f); do
        APK_TO_DUMP=$(echo "$APP" | sed "s/^package://" | sed "s/base.apk=/base.apk /").apk
        DUMPED_APK_PATH=$(echo "$APK_TO_DUMP" | awk '{ print $1 }')
        DUMPED_APK_NAME=$(echo "$APK_TO_DUMP" | awk '{ print $2 }')
        if [[ -n $DUMPED_APK_NAME ]]; then
            echo -e "$((INDEX++)). Name: $DUMPED_APK_NAME - Path: $DUMPED_APK_PATH"
        else
            echo -e "$((INDEX++)). Path: $DUMPED_APK_PATH"
        fi
    done
}

# Usage
[[ $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0") [app-type] (user|system)\n" && exit 1

# Checks
[[ -f $DUMP_LOG ]] && rm -fv "$EXPORT_LOG"
[[ -z $DUMP_TYPE ]] && DUMP_TYPE="all"
# [[ -z $DUMP_TYPE ]] && echo -e "\nError: You must define the application type you want to dump.\n" && exit 1

# Arguments
case "${DUMP_TYPE,,}" in
    user) DUMP_ARG="-3" ;;
    system) DUMP_ARG="-s" ;;
    all) DUMP_ARG= ;;
    *) echo -e "\nError: Invalid application type given. Only 'user' or 'system' types are supported.\n" && exit 1 ;;
esac

# Main
list_devices
list_apps
