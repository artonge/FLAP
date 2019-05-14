#!/bin/bash

set -e

# Empty main.cron
echo "" > ./main.cron

# Fill main.cron from services cron files
for service in $(ls)
do
    if [ -f ./${service}/${service}.cron ]
    then
        cat ./${service}/${service}.cron >> ./main.cron
    fi
done

# Set main.cron as the cron file
crontab ./main.cron