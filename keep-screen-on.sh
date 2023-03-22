#!/usr/bin/env bash

# Basic Android device screen wakeup script
# Made by Jiab77 / 2023
#
# References:
# - https://stackoverflow.com/questions/8840954/how-do-i-keep-my-screen-unlocked-during-usb-debugging/27681288#27681288
# - https://stackoverflow.com/questions/8840954/how-do-i-keep-my-screen-unlocked-during-usb-debugging/43364859#43364859
#
# Version 0.0.0

# Options
set +o xtrace

# Config
AWAKE_INTERVAL=5

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
function wakeup() {
    echo -e "\nKeeping device screen awake...\n"
    while true; do date "+%H:%M:%S   %d-%m-%y  -  wake up device"; adb shell input keyevent mouse; sleep $AWAKE_INTERVAL; done
}
function init() {
    get_devices
    list_devices
    wakeup
}

# Usage
[[ $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0")\n" && exit 1

# Checks

# Main
init