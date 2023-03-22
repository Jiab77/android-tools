#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2126,SC2129

# Basic Zcash wallet sync monitoring for Edge app
# Made by Jiab77 / 2023
#
# References:
#
# Version 0.0.0

# Options
set -o xtrace

# Config
SCREEN_FILE="/tmp/.screenrc"

# Functions
function list_devices() {
    echo -e "\nListing attached devices...\n"
    adb devices -l | grep -vi "list"
}
function get_devices() {
    echo -e "\nGathering attached devices...\n"
    if [[ $(adb devices -l | grep -vi "list" | head -n1 | wc -l) -eq 0 ]]; then
        echo -e "\nError: No attached devices found.\n"
        exit 1
    fi
}
function create_screen_file() {
    echo "startup_message off" >  "$SCREEN_FILE"
    echo "defscrollback 10000" >> "$SCREEN_FILE"
    echo "screen -t logcat_edge adb logcat | grep --color=always -iE 'co.edgesecure.app|downloading'" >> "$SCREEN_FILE"
    echo "screen -t wakeup_device ./keep-screen-on.sh" >> "$SCREEN_FILE"
    echo "screen -t logcat_nh adb logcat | grep com.nighthawkapps.wallet.android" >> "$SCREEN_FILE"
    if [[ -z $SCREEN_FILE ]]; then
        echo -e "\nError: Screen file is empty.\n"
        exit 1
    else
        echo -e "\nScreen file created.\n"
    fi
}
function remove_screen_file() {
    rm -f $SCREEN_FILE
}
function run_screen() {
    echo -e "\nStarting screen...\n"
    screen -c $SCREEN_FILE
}
function run_edge_monitor() {
    adb logcat | grep --color=always -iE 'co.edgesecure.app|downloading'
}
function init() {
    get_devices
    list_devices
    # create_screen_file
    # run_screen
    run_edge_monitor
}

# Usage
[[ $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0")\n" && exit 1

# Checks

# Main
init
remove_screen_file