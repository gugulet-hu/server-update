#!/bin/sh
# This script updates plugins and the wordpress core for gugulet.hu and thelocaltourist.co.za and updating the Piwik and Nextcloud apps.
# Version 4.1 (3 February 2020)

# Set evironment path for running with Crontab
export PATH=/usr/local/cpanel/3rdparty/lib/path-bin:/usr/local/cpanel/3rdparty/lib/path-bin:/usr/local/cpanel/3rdparty/lib/path-bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/cpanel/composer/bin:/home/guguleth/.local/bin:/home/guguleth/bin
export MAIL=/var/spool/mail/guguleth

#Set script file and directory variables
export LOG=/home/guguleth/server-updater-log.txt
export WORDPRESS=/home/guguleth/public_html/site/
export MATOMO=/home/guguleth/public_html/site/wp-content/plugins/matomo/app/
export NEXTCLOUD=/home/guguleth/public_html/cloud/

# Writes the header for the log file: Program, Version number, Date and Line.
{ echo "ServerUpdater 4.0"; echo "Log: " `date`; printf "\n"; printf "\n"; } > $LOG

# Function: Reviews the last command for errors. Then prints update complete to log or shows error dialog. Takes section variable.
catcher () {
if [ "$?" = "0" ]; then
    printf "$1 updates complete." >> $LOG # If no error, print update complete to file.
    printf "\n" >> $LOG # Add a line to file.
    printf "\n" >> $LOG # Add a line to file.
else # If error, show a dialog stating the section where the error occured.
    printf "$1 updates failed." >> $LOG # If error, print update complete to file. 
    printf "\n" >> $LOG # Add a line to file.
    printf "\n" >> $LOG # Add a line to file.
    ERROR=1
fi
}

# Function: If there has been an error in the script open the log file.
verify () {
if [ $ERROR=1 ]; then
    printf "All updates completed with errors. END" >> $LOG
    echo "$(cat $LOG)" | mail -s "Server Update Error" postmaster@gugulet.hu
else
    printf "All updates completed. END" >> $LOG
fi
}

# Wordpress updates.
printf "WORDPRESS" >> $LOG
printf "\n" >> $LOG
{ cd $WORDPRESS/; wp cli update; wp cli cache clear; wp core update; wp checksum core; wp core update-db; wp db export /home/guguleth/files/gugulethu/files/gugulet.hu/Database/latest-db.sql; wp db repair; wp db optimize; wp export --dir=/home/guguleth/files/gugulethu/files/gugulet.hu/XML/; wp wp-sec check; wp plugin update --all; wp plugin verify-checksums --all; wp theme update --all; wp transient delete --all; cp -ra /home/guguleth/public_html/site/* /home/guguleth/files/gugulethu/files/gugulet.hu/Files/; cp /home/guguleth/site-config.php /home/guguleth/files/gugulethu/files/gugulet.hu/Files/wp-config.php; } >> $LOG
catcher Wordpress

# Matomo updates.
printf "MATOMO" >> $LOG
{ cd $MATOMO; php console core:update; php console core:clear-caches; php console database:optimize-archive-tables all; php console cache:clear; } >> $LOG
catcher Matomo


# Nextcloud updates.
printf "NEXTCLOUD" >> $LOG
printf "\n" >> $LOG
{ cd $NEXTCLOUD; php /home/guguleth/public_html/cloud/updater/updater.phar; php occ integrity:check-core; php occ app:update --all; php occ files:cleanup; php occ files:scan --all;  } >> $LOG
catcher Nextcloud

verify $ERROR