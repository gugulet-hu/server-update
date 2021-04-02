#!/bin/sh
# This script updates php apps. Place it in the root.
# Version 4.1.1 (10 September 2020)

# Set evironment path for running with Crontab
export PATH=/path-to-your-bin-folder/bin
export MAIL=/path-to-your-php-mail-folder/

#Set script file and directory variables
export LOG=/path/server-updater-log.txt
export WORDPRESS=/path-to-wordpress-install/
export MATOMO=/path-to-matomo-install/matomo/app/
export NEXTCLOUD=/path-to-nextcloud-install/

# Writes the header for the log file: Program, Version number, Date and Line.
{ echo "ServerUpdater 4.1"; echo "Log: " `date`; printf "\n"; printf "\n"; } > $LOG

# Function: Reviews the last command for errors. Then prints update complete to log and / or error.
catcher () {
if [ "$?" = "0" ]; then
    printf "$1 updates complete." >> $LOG # If no error, print update complete to file.
    printf "\n" >> $LOG # Add a line to file.
    printf "\n" >> $LOG # Add a line to file.
else #
    printf "$1 updates failed." >> $LOG # If error, print update complete to file. 
    printf "\n" >> $LOG # Add a line to file.
    printf "\n" >> $LOG # Add a line to file.
    ERROR=1 # Print error
fi
}

# Function: If there has been an error in the script send an email with the log file attached.
verify () {
if [ $ERROR=1 ]; then
    printf "All updates completed with errors. END" >> $LOG
    echo "$(cat $LOG)" | mail -s "Server Update Error" error@youremailaddress.com
else
    printf "All updates completed. END" >> $LOG
fi
}

# Wordpress updates.
printf "WORDPRESS" >> $LOG
printf "\n" >> $LOG
{ cd $WORDPRESS/;

# Saves the current Wordpress files
wp db export /path-where-you-want-to-save-db/latest-db.sql;
wp export --dir=/path-where-you-want-to-save-xml/;
cp $WORDPRESS/wp-config.php /path-where-you-want-to-save-config/;
cp -ra $WORDPRESS/* /path-where-you-want-to-save-wordpress-files/;

# Optimise and update Wordpress
wp cli update; wp cli cache clear; wp core update; wp checksum core; wp core update-db; wp db repair; wp db optimize; wp wp-sec check; wp plugin update --all; wp plugin verify-checksums --all; wp theme update --all; wp transient delete --all;   } >> $LOG
catcher Wordpress

# Matomo updates.
printf "MATOMO" >> $LOG
{ cd $MATOMO; php console core:update; php console core:clear-caches; php console database:optimize-archive-tables all; php console cache:clear; } >> $LOG
catcher Matomo


# Nextcloud updates.
printf "NEXTCLOUD" >> $LOG
printf "\n" >> $LOG
{ cd $NEXTCLOUD; php $NEXTCLOUD/updater/updater.phar; php occ integrity:check-core; php occ app:update --all; php occ files:cleanup; php occ files:scan --all;  } >> $LOG
catcher Nextcloud

verify $ERROR