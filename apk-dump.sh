#!/usr/bin/env bash

# Basic Android APK files dump script
# Made by Jiab77 / 2023
#
# References:
# - https://gist.github.com/AnatomicJC/e773dd55ae60ab0b2d6dd2351eb977c1
#
# Version 0.0.1

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Config
EXPORT_TYPE=$1
EXPORT_FOLDER=$2
EXPORT_LOG="$(basename "$0" | sed -e 's/.sh//i').errors.log"

# Functions
function list_devices() {
    echo -e "\nListing attached devices...\n"
    adb devices -l | grep -vi "list"
}
function dump_apps() {
    mkdir -pv "$EXPORT_FOLDER"
    for APP in $(adb shell pm list packages "$EXPORT_ARG" -f); do
        APK_TO_DUMP=$( echo "$APP" | sed "s/^package://" | sed "s/base.apk=/base.apk /").apk
        DUMPED_APK=$(echo "$APK_TO_DUMP" | awk '{ print $2 }')
        if [[ -n $DUMPED_APK ]]; then
            echo -e "\nDumping ${DUMPED_APK}...\n"
            adb pull "$APK_TO_DUMP"
            RET_CODE=$?
            # echo -e "\nGot: ${RET_CODE}\n"
            if [[ $RET_CODE -eq 0 ]]; then
                echo -e "\nMoving ${DUMPED_APK}...\n"
                mv -v "$DUMPED_APK" "$EXPORT_FOLDER"/
            fi
        else
            echo "${APK_TO_DUMP}" >> "$EXPORT_LOG"
        fi
    done
}

# Usage
[[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0") <app-type> (user|system) <dump-folder>\n" && exit 1

# Checks
[[ -f $EXPORT_LOG ]] && rm -fv "$EXPORT_LOG"
[[ -z $EXPORT_TYPE ]] && echo -e "\nError: You must define the application type you want to dump.\n" && exit 1
[[ -z $EXPORT_FOLDER ]] && echo -e "\nError: You must define the dump folder.\n" && exit 1
[[ -f $EXPORT_FOLDER ]] && echo -e "\nError: '$EXPORT_FOLDER' is not a folder.\n" && exit 1

# Arguments
case "${EXPORT_TYPE,,}" in
    user) EXPORT_ARG="-3" ;;
    system) EXPORT_ARG="-s" ;;
    *) echo -e "\nError: Invalid application type given. Only 'user' or 'system' types are supported.\n" && exit 1 ;;
esac

# Main
list_devices
dump_apps
