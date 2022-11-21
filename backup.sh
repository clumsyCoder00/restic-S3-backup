#!/bin/bash

# Revise to check for offsite being available, sync if so

# configure auto-run with sudo crontab -e
# 0 2 * * * '/path/to/folder/backup.sh'

# ---- Restic Info ----
# TODO
# https://forum.restic.net/t/huge-amount-of-data-read-from-s3-backend/2321
# x create local repository on 3TB drive
# x move excludes to exclude file
# x upgrade repository to latest 13.1 version
# - delete older snapshots
# x prune B2 repository, with forget command below, use the --max-unsued option
# x run check on repository
# x figure out what data can be moved to deep archive, looks like everything with the exception of the data dir
#    https://forum.restic.net/t/s3-deep-glacier-any-experience-with-costs/3285/4
#    https://forum.restic.net/t/s3-deep-glacier-any-experience-with-costs/3285/19


# restic commands
# use source with sudo
# sudo su
# source '/home/nuthanael/Documents/backup/restic/.Lo.restic.env'
# restic check
# restic prune

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
ExcPath="$SCRIPTPATH/exclude.txt"

# ---- Cloud ----
#echo $(readlink -f "$ErrPath")

LoSource="$SCRIPTPATH/restic/.LO.env"
LoFiles="$SCRIPTPATH/restic/LO.files"
LoLogPath="$SCRIPTPATH/restic/LO.log"

LoExcPath="$SCRIPTPATH/restic/LO exclude.txt"

B2Source="$SCRIPTPATH/restic/.B2.env"
B2Files="$SCRIPTPATH/restic/B2.files"
B2LogPath="$SCRIPTPATH/restic/B2.log"

B2ExcPath="$SCRIPTPATH/restic/B2 exclude.txt"

S3Source="$SCRIPTPATH/restic/.S3.env"
S3Files="$SCRIPTPATH/restic/S3.files"
S3LogPath="$SCRIPTPATH/restic/S3.log"

S3ExcPath="$SCRIPTPATH/restic/S3 exclude.txt"
# ---- End Paths ----

printf "\n$(date +'%Y-%m-%d %H:%M:%S') ---- Start Backup ----\n" >> "$LogPath"
#exit
# - --- FatCat-HP ----
# 2022.10.14
# -avAX
# -axHAWXS --numeric-ids --info=progress2
printf "$(date +'%Y-%m-%d %H:%M:%S') ---- FatCat-HP -> pond ----\n" >> "$LogPath"
sudo rsync -axHAWXS --numeric-ids --info=progress2 --delete --exclude-from "$ExcPath" --delete-excluded / '/mnt/pond/backups/FatCat-HP' 2>> "$ErrPath" > "$VerbosePath"

# ---- swamp ----
#printf "$(date +'%Y-%m-%d %H:%M:%S') ---- /pond/backups -> swamp ----\n" >> "$LogPath"
#sudo rsync -avAX --delete --force --exclude={'Media Server'} --delete-excluded '/mnt/pond/backups/FatCat-HP/' '/mnt/swamp/backups/FatCat-HP' 2>> "$ErrPath" >> "$VerbosePath"

#printf "$(date +'%Y-%m-%d %H:%M:%S') ---- /pond/serverData -> swamp ----\n" >> "$LogPath"
#sudo rsync -avAX --delete --force --exclude={"*._*, /.zfs/***","./zfs/"} --delete-excluded '/mnt/pond/serverData/' '/mnt/swamp/serverData' 2>> "$ErrPath" >> "$VerbosePath"

# printf "$(date +'%Y-%m-%d %H:%M:%S') ---- /pond/media -> swamp ----\n" >> "$LogPath"
# sudo rsync -avAX --delete --force --exclude={"*._*, /.zfs/***","./zfs/"} --delete-excluded '/mnt/pond/media/' '/mnt/swamp/media' 2>> "$ErrPath" >> "$VerbosePath"

# variables to use as needed---- --verbose=2 --dry-run
printf "$(date +'%Y-%m-%d %H:%M:%S') ---- Local Backup ----\n" >> "$ErrPath"
source "$LoSource"
restic backup --files-from "$LoFiles" --tag "$(date "+%Y-%m-%d %T")" --verbose=1 --exclude-file="$LoExcPath" 2>> "$ErrPath" > "$LoLogPath"
restic forget --keep-within-daily 7d --keep-within-weekly 1m --prune >> "$ErrPath" > "$LoLogPath"

# ---- B2 Server/Nextcloud Backup ----
printf "$(date +'%Y-%m-%d %H:%M:%S') ---- B2 Backup ----\n" >> "$ErrPath"
source "$B2Source"
restic backup --files-from "$B2Files" --tag "$(date "+%Y-%m-%d %T")" --verbose=1 --exclude-file="$B2ExcPath" 2>> "$ErrPath" > "$B2LogPath"
restic forget --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --prune >> "$ErrPath" > "$B2LogPath"

# ---- S3 Media Backup ----
source "$S3Source"
printf "$(date +'%Y-%m-%d %H:%M:%S') ---- S3 Backup ----\n" >> "$ErrPath"
restic backup --files-from "$S3Files" --tag "$(date "+%Y-%m-%d %T")" --verbose=1 --exclude-file="$S3ExcPath" 2>> "$ErrPath" > "$S3LogPath"

printf "$(date +'%Y-%m-%d %H:%M:%S') ---- Backup Complete ----\n\n" >> "$LogPath"
