#!/bin/bash

set -e

# Empty main.cron
echo "" > ./main.cron

# Fill main.cron from services cron files
for service in $(ls $FLAP_DIR)
do
    if [ -f $FLAP_DIR/$service/$service.cron ]
    then
        cat $FLAP_DIR/$service/$service.cron >> ./main.cron
    fi
done

# Set main.cron as the cron file
crontab ./main.cron