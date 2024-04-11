#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2126,SC2129

# Basic Zcash wallet sync monitoring for any app
# Made by Jiab77 / 2023
#
# References:
#
# Version 0.0.0

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Config
APP_TO_WATCH="$1"
DUMP_ARG="-3"
SHOW_APP_LIST=false

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
function get_devices() {
    echo -e "\nGathering attached devices...\n"
    if [[ $(adb devices -l | grep -vi "list" | head -n1 | wc -l) -eq 0 ]]; then
        echo -e "\nError: No attached devices found.\n"
        exit 1
    fi
}
function get_user_wallet_app() {
    list_apps
    echo ; read -rp "Select wallet application [ID]: " APP_ID
    APP_TO_WATCH=$(list_apps | grep "${APP_ID}\." | awk '{ print $3 }' | head -n1 | sed -e 's/.apk//gi')
    echo -e "\nSelected app: ${APP_TO_WATCH}\n"
    read -rp "Confirm selection? [Y,N]: " CONFIRM_APP
    if [[ "${CONFIRM_APP,,}" == "n" ]]; then
        echo -e "\nOk fine, please run the script again to select another app.\n"
        exit 1
    fi
}
function run_wallet_monitor() {
    echo -e "\nMonitoring [$APP_TO_WATCH] app...\n"
    adb logcat | grep --color=always -iE ''"${APP_TO_WATCH}"'|downloading'
}
function init() {
    get_devices
    list_devices
    [[ $SHOW_APP_LIST == true ]] && get_user_wallet_app
    run_wallet_monitor
}

# Usage
[[ $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0") [wallet-app] (e.g. co.edgesecure.app, com.nighthawkapps.wallet, io.horizontalsystems.bankwallet)\n" && exit 1

# Checks
[[ $# -eq 0 ]] && SHOW_APP_LIST=true

# Main
init
