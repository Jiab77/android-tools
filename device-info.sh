#!/usr/bin/env bash

# Basic Android device information gathering script
# Made by Jiab77 / 2023
#
# References:
# - https://github.com/mzlogin/awesome-adb/blob/master/README.en.md
#
# Version 0.0.0

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Config
LIST_DEVICES_ONLY=false

# Functions
function list_devices() {
    echo -e "\nListing attached devices...\n"
    adb devices -l | grep -vi "list"
}
function gather_device_info() {
    echo -e "\nGathering device information..."
    echo -e "\n- Model: $(adb shell getprop ro.product.model)"
    echo -e "\n- Device ID: $(adb shell settings get secure android_id)"
    echo -e "\n- Device IMEI: $(adb shell dumpsys iphonesubinfo)"
    echo -e "\n- Android version: $(adb shell getprop ro.build.version.release)"
    echo -e "\n- CPUs:\n\n$(adb shell cat /proc/cpuinfo)"
    echo -e "\n- Memory:\n\n$(adb shell cat /proc/meminfo)"
    echo -e "\n- Screen size:\n\n$(adb shell wm size)"
    echo -e "\n- Screen density:\n\n$(adb shell wm density)"
    echo -e "\n- Display:\n\n$(adb shell dumpsys window displays)"
    echo -e "\n- Network IPs:\n\n$(adb shell ifconfig | grep Mask)"
    echo -e "\n- Network interfaces:\n$(adb shell netcfg)"
    echo -e "\n- Hardware properties:\n$(adb shell cat /system/build.prop)"
}

# Usage
[[ $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0")\n" && exit 1

# Checks
[[ $1 == "--short" ]] && LIST_DEVICES_ONLY=true

# Main
if [[ $LIST_DEVICES_ONLY == true ]]; then
    list_devices
else
    list_devices
    gather_device_info
fi
