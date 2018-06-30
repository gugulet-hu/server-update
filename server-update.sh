#!/bin/sh
# This script updates plugins and the wordpress core for gugulet.hu and thelocaltourist.co.za and updating the Piwik and Nextcloud apps.
# Version 2.0 (17 July 2018)

# Update Wordpress files and WP-CLI.
ssh guguleth@gugulet.hu 'php wp-cli.phar cli update' 
ssh guguleth@gugulet.hu 'php wp-cli.phar cli update'
ssh guguleth@gugulet.hu 'php wp-cli.phar core update'
ssh guguleth@gugulet.hu 'php wp-cli.phar checksum core'
ssh guguleth@gugulet.hu 'php wp-cli.phar plugin update --all'
ssh guguleth@gugulet.hu 'php wp-cli.phar theme update --all'
ssh guguleth@gugulet.hu 'php wp-cli.phar transient delete --all'
ssh guguleth@gugulet.hu 'php wp-cli.phar db optimize'

# Update Matomo.
ssh guguleth@gugulet.hu 'cd ~/public_html/analytics/ php console core:update'
ssh guguleth@gugulet.hu 'cd ~/public_html/analytics/ php console cache:clear'

# Update Nextcloud.
ssh guguleth@gugulet.hu 'cd ~/public_html/cloud/ php updater/updater.phar'
ssh guguleth@gugulet.hu 'cd ~/public_html/cloud/ php occ upgrade'
ssh guguleth@gugulet.hu 'cd ~/public_html/cloud/ php occ files:cleanup'
ssh guguleth@gugulet.hu 'cd ~/public_html/cloud/ php occ files:cleanup'

# Displaying notification that the updates are done
osascript -e 'display notification "Server updates are complete." with title "Server Updater"'