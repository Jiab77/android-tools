#!/usr/bin/env bash

# Basic Android device connection script
# Made by Jiab77 / 2023
#
# References:
# - https://developer.android.com/studio/command-line/adb
# - https://medium.com/@amanshuraikwar.in/connecting-to-android-device-with-adb-over-wifi-made-a-little-easy-39439d69b86b
# - https://gist.github.com/peter-tackage/ab337d76d47624de45be9327a0c8dedc
#
# Version 0.0.0

# Options
set -o xtrace

# Config
DEFAULT_PORT=5555
USE_USB=false
USE_WIRELESS=false
WIRELESS_METHOD1=false
WIRELESS_METHOD2=false
KILL_SERVER_BEFORE_INIT=true

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
function usb_connect() {
    echo -e "\nConnecting to USB device...\n"
    adb start-server
}
function wireless_connect_type1() {
    echo -e "\nTrying newer wireless connection method...\n"
    read -rp "Device IP address: " DEVICE_IP
    read -rp "Device connection port: " DEVICE_PORT
    if [[ -n $DEVICE_IP && -n $DEVICE_PORT ]]; then
        echo -e "\nConnecting to ${DEVICE_IP}:${DEVICE_PORT}...\n"
        adb pair "${DEVICE_IP}:${DEVICE_PORT}"
        RET_CODE_PAIRING=$?
        if [[ $RET_CODE_PAIRING -ne 0 ]]; then
            echo -e "\nError: Method not supported on this device. Please try the other one.\n"
            exit 1
        fi
    else
        echo -e "\nError: Method not supported on this device. Please try the other one.\n"
        exit 1
    fi
}
function wireless_connect_type2() {
    echo -e "\nTrying older wireless connection method...\n"
    read -rp "Device IP address: " DEVICE_IP
    if [[ -n $DEVICE_IP ]]; then
        echo -e "\nPreparing device connection via port ${DEFAULT_PORT}...\n"
        adb tcpip $DEFAULT_PORT
        echo -e "\nConnecting to ${DEVICE_IP}:${DEFAULT_PORT}...\n"
        adb connect "${DEVICE_IP}:${DEFAULT_PORT}"
        RET_CODE_CONNECT=$?
        if [[ $RET_CODE_CONNECT -ne 0 ]]; then
            echo -e "\nError: Method not supported on this device. Please try the other one.\n"
            exit 1
        fi
    else
        echo -e "\nError: Method not supported on this device. Please try the other one.\n"
        exit 1
    fi
}
function kill_server() {
    echo -e "\nKilling adb server...\n"
    adb kill-server
}
function init() {
    if [[ $KILL_SERVER_BEFORE_INIT == true ]]; then
        kill_server
    fi

    if [[ $USE_USB == true ]]; then
        usb_connect
    elif [[ $USE_WIRELESS == true ]]; then
        if [[ $WIRELESS_METHOD1 == true ]]; then
            wireless_connect_type1
        elif [[ $WIRELESS_METHOD2 == true ]]; then
            wireless_connect_type2
        else
            echo -e "\nError: Unsupported wireless connection type given.\n"
            exit 1
        fi
    else
        echo -e "\nError: Unsupported connection method given.\n"
        exit 1
    fi
}

# Usage
[[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0") <usb|wireless> [--type 1|2]\n" && exit 1

# Checks
[[ "${1,,}" == "usb" ]] && USE_USB=true
[[ "${1,,}" == "wireless" ]] && USE_WIRELESS=true
[[ $# -eq 3 && $3 == 1 ]] && WIRELESS_METHOD1=true
[[ $# -eq 3 && $3 == 2 ]] && WIRELESS_METHOD2=true

# Main
init
get_devices
list_devices
