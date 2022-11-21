## ---- restic cheat sheet ----  
This collection of files function as an S3 backup for the machine on which they reside  

Script is executed through a crontab job  
Because some filed being backed up bave access restriction from the normal user, script is called from the super user cron
This is accessed with: `sudo crontab -e` if super user access isn't required, the normal user cron ias accessed with `crontab -e`

The script is executed at 2am every day with the following line in the crontab file:  
`0 2 * * * '/path/tofolder/backup.sh'`  

Using this script, encryped files are copied to the specified S3 bucket using restic. Objects in data directory of this S3 bucket are moved to S3 Glacier Deep Archive after 1 Day using a lifecycle rule. Files are not accessible while in Deep Archive storage. They must be moved back out in order to be accessible to restic or any other process.

discussion on using restic to store data in Deep Archive storage  
https://forum.restic.net/t/huge-amount-of-data-read-from-s3-backend/2321

discussion on the costs associated with backing up to Deep archive  
https://forum.restic.net/t/s3-deep-glacier-any-experience-with-costs/3285/4  
https://forum.restic.net/t/s3-deep-glacier-any-experience-with-costs/3285/19  

how to use use the source command with sudo  
`sudo su`  
`source '/home/nuthanael/Documents/backup/restic/.Lo.restic.env'`  

`restic init` - create a new respository in bucket  
`restic check` - verify data is properly stored in repository  
`restic snapshots` - list snapshots in existing repository  
`restic restore 'snapshot_name' --target 'restore_path'` - restore a partiuclar snapshot  
`restic forget 'snapshot_name' --prune` - delete snapshots, prune aws storage  
`restic forget --keep-tag anything --prune` - delete snapshots, prune aws storage  
`restic backup --files-from restic.files --tag seed (--dry-run) (--verbose=2)`  
`restic prune` - remove unreferenced packs - started backing up data I didn't want, completed subsequent backup. now unwanted data is no longer referenced by any current, complete snapshot  

### cache
https://restic.readthedocs.io/en/latest/manual_rest.html#caching  
set cache directory with `XDG_CACHE_HOME`  
#### This needs to be backed up in order to access snapshot info without access to Glacier archive

forget  
`forget --keep-within-daily 7d --keep-within-weekly 1m --keep-within-monthly 1y --keep-within-yearly 75y --prune`

### set S3 Storage Class  
`-o s3.storage-class=REDUCED_REDUNDANCY`  
`STANDARD, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, REDUCED_REDUNDANCY`  
