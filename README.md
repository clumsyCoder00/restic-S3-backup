# restic-B2-S3-local
This script functions as an S3 backup for the machine on which it resides

Script is executed through a crontab job
because some filed being backed up bave access restriction from the normal user, script is called from the super user cron
This is accessed with: `sudo crontab -e` if super user access isn't required, the normal user cron ias accessed with `crontab -e`

The script is executed at 2am every day with the following line in the crontab file:  
`0 2 * * * '/path/tofolder/backup.sh'`

Using this script, encryped files are copied to the specified S3 bucket using restic. Objects in data directory of this S3 bucket are moved to S3 Glacier Deep Archive after 1 Day. Files are not accessible while in Deep Archive storage. They must be moved back out in order to be accessible to restic or any other process.
