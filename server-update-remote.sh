#!/bin/sh
# This script updates plugins and the wordpress core for gugulet.hu and thelocaltourist.co.za and updating the Piwik and Nextcloud apps.
# Version 3.0 (15 July 2018)

# Writes the header for the log file: Program, Version number, Date and Line.
{ echo "ServerUpdater 3.0"; echo "Log: " `date`; line; } > /home/guguleth/server-updater-log.txt

# Function: Reviews the last command for errors. Then prints update complete to log or shows error dialog. Takes section variable.
catcher () {
if [ "$?" = "0" ]; then
    printf "$1 updates complete." >> /home/guguleth/server-updater-log.txt # If no error, print update complete to file.
    printf "" >> /home/guguleth/server-updater-log.txt # Add a line to file.
else # If error, show a dialog stating the section where the error occured.
    printf "$1 updates failed." >> /home/guguleth/server-updater-log.txt # If error, print update complete to file. 
fi
}

# Function: Creates a horizontal line in the text file.
line () {
echo "" >> /home/guguleth/server-updater-log.txt # Starts the horizontal line on its own fresh line.
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - >> /home/guguleth/server-updater-log.txt # Prints line
}

# Wordpress updates.
{ cd ~/ php wp-cli.phar cli update; cd ~/ php wp-cli.phar cli update; cd ~/ php wp-cli.phar core update; cd ~/ php wp-cli.phar checksum core; cd ~/ php wp-cli.phar plugin update --all; cd ~/ php wp-cli.phar theme update --all; cd ~/ php wp-cli.phar transient delete --all; cd ~/ php wp-cli.phar db optimize; } >> /home/guguleth/server-updater-log.txt
catcher Wordpress
line

# Matomo updates.
{ cd ~/public_html/analytics/ php console core:update; cd ~/public_html/analytics/ php console cache:clear; } >> /home/guguleth/server-updater-log.txt
catcher Matomo
line

# Nextcloud updates.
{ cd ~/public_html/cloud/ php updater/updater.phar; cd ~/public_html/cloud/ php occ upgrade; cd ~/public_html/cloud/ php occ files:cleanup; cd ~/public_html/cloud/ php occ files:cleanup; } >> /home/guguleth/server-updater-log.txt
catcher Nextcloud
line

# Prints and shows dialog box confirming all updates are done.
printf "All updates complete. END" >> /home/guguleth/server-updater-log.txt