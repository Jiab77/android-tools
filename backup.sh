#!/usr/bin/env bash

# Basic Android backup script
# Made by Jiab77 / 2023
#
# References:
# - https://gist.github.com/AnatomicJC/e773dd55ae60ab0b2d6dd2351eb977c1
# - https://riptutorial.com/android/example/11498/backup
#
# Version 0.0.0

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Config
BACKUP_TYPE=$1
BACKUP_LOG="$(basename "$0" | sed -e 's/.sh//i').errors.log"
BACKUP_NAME="$(basename "$0" | sed -e 's/.sh//i').$(date +%Y%m%d%H%M%S).ab"

# Functions
function list_devices() {
    echo -e "\nListing attached devices...\n"
    adb devices -l | grep -vi "list"
}
function full_backup() {
    echo -e "\nRunning 'full' backup...\n"
    # adb backup "$BACKUP_ARGS" -f "$BACKUP_FOLDER"/"$BACKUP_NAME"
    adb shell 'bu backup '"$BACKUP_ARGS"'' > "$BACKUP_FOLDER"/"$BACKUP_NAME"
}
function app_backup() {
    echo -e "\nRunning 'app' backup...\n"
    # adb backup "$BACKUP_ARGS" -f "$BACKUP_FOLDER"/"$BACKUP_NAME"
    adb shell 'bu backup '"$BACKUP_ARGS"'' > "$BACKUP_FOLDER"/"$BACKUP_NAME"
}
function check_app_name() {
    [[ -z $APP_TO_BACKUP || -d $APP_TO_BACKUP ]] && echo -e "\nError: You must define the application to backup.\n" && exit 1
}
function check_backup_folder() {
    [[ -z $BACKUP_FOLDER ]] && echo -e "\nError: You must define the backup folder.\n" && exit 1
    [[ -f $BACKUP_FOLDER ]] && echo -e "\nError: '$BACKUP_FOLDER' is not a folder.\n" && exit 1
}
function create_backup_folder() {
    mkdir -pv "$BACKUP_FOLDER"
}

# Usage
[[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]] && echo -e "\nUsage: $(basename "$0") <backup-type> (full|app) [app-name] <backup-folder>\n" && exit 1

# Checks
[[ -f $BACKUP_LOG ]] && rm -fv "$BACKUP_LOG"
[[ -z $BACKUP_TYPE ]] && echo -e "\nError: You must define the backup type you want to make.\n" && exit 1

# Main
list_devices
case "${BACKUP_TYPE,,}" in
    full)
        BACKUP_ARGS="-apk -all -obb -shared -system"
        # BACKUP_ARGS="-apk -all -noobb -shared -system"
        # BACKUP_ARGS="-apk -all -noobb -noshared -system"
        # BACKUP_ARGS="-apk -all -noobb -noshared -nosystem"
        BACKUP_FOLDER=$2

        check_backup_folder
        create_backup_folder
        full_backup
    ;;
    app)
        APP_TO_BACKUP="$2"
        # BACKUP_ARGS="-apk $APP_TO_BACKUP"
        BACKUP_ARGS="-apk $APP_TO_BACKUP -obb"
        BACKUP_FOLDER=$3

        check_app_name
        check_backup_folder
        create_backup_folder
        app_backup
    ;;
    *) echo -e "\nError: Invalid application type given. Only 'full' or 'app' types are supported.\n" && exit 1 ;;
esac
