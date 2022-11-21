#!/bin/bash

# configure auto-run with sudo crontab -e
# 0 2 * * * '/path/to/folder/backup.sh'

# ---- Restic Info ----
# TODO
# https://forum.restic.net/t/huge-amount-of-data-read-from-s3-backend/2321

# x figure out what data can be moved to deep archive, looks like everything with the exception of the data dir
#    https://forum.restic.net/t/s3-deep-glacier-any-experience-with-costs/3285/4
#    https://forum.restic.net/t/s3-deep-glacier-any-experience-with-costs/3285/19


# restic commands
# use source with sudo
# sudo su
# source '/home/nuthanael/Documents/backup/restic/.Lo.restic.env'

# restic init - create a new respository in bucket
# restic check - verify data is properly stored in repository
# restic snapshots - list snapshots in existing repository
# restic restore 'snapshot_name' --target 'restore_path' - restore a partiuclar snapshot
# restic forget 'snapshot_name' --prune - delete snapshots, prune aws storage
# restic forget --keep-tag anything --prune - delete snapshots, prune aws storage
# restic backup --files-from restic.files --tag seed (--dry-run) (--verbose=2)
# restic prune - remove unreferenced packs - started backing up data I didn't want, completed subsequent backup. now unwanted data is no longer referenced by any current, complete snapshot

# cache
# https://restic.readthedocs.io/en/latest/manual_rest.html#caching
# set cache directory with XDG_CACHE_HOME
# this needs to be backed up in order to access snapshot info without access to Glacier archive

# forget
# forget --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 75y --prune

# set S3 Storage Class
# -o s3.storage-class=REDUCED_REDUNDANCY
# STANDARD, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, REDUCED_REDUNDANCY
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
