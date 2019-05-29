#!/bin/bash

set -e

echo "FETCHING REPO"
git pull
git submodule update

echo "RUNNING POST-UPDATE SCRIPTS"
# Run post update scripts for each services
for service in $(ls $FLAP_DIR)
do
    if [ -f $FLAP_DIR/$service/scripts/post_update.sh ]
    then
        $FLAP_DIR/$service/scripts/post_update.sh
    fi
done

echo "GENERATING CONFIGURATION"
manager setup cron
manager config generate

echo "RESTARTING SERVICES"
docker-compose down
docker-compose up -d
