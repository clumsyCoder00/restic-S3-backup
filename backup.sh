#!/bin/bash

# ---- Restic Info ----

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

LogPath="$SCRIPTPATH/backup.log"
ErrPath="$SCRIPTPATH/backup.log"
VerbosePath="$SCRIPTPATH/backup_verbose.log"

# ---- Cloud ----
#echo $(readlink -f "$ErrPath")

S3Source="$SCRIPTPATH/restic/.S3.env"
S3Files="$SCRIPTPATH/restic/S3.files"
S3LogPath="$SCRIPTPATH/restic/S3.log"

S3ExcPath="$SCRIPTPATH/restic/S3 exclude.txt"
# ---- End Paths ----

printf "\n$(date +'%Y-%m-%d %H:%M:%S') ---- Start Backup ----\n" >> "$LogPath"

# ---- S3 Media Backup ----
source "$S3Source"
printf "$(date +'%Y-%m-%d %H:%M:%S') ---- S3 Backup ----\n" >> "$ErrPath"
restic backup --files-from "$S3Files" --tag "$(date "+%Y-%m-%d %T")" --verbose=1 --exclude-file="$S3ExcPath" 2>> "$ErrPath" > "$S3LogPath"

printf "$(date +'%Y-%m-%d %H:%M:%S') ---- Backup Complete ----\n\n" >> "$LogPath"
