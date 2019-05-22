#!/bin/bash

set -e

git pull
git submodule update

# Run post update scripts for each services
for service in $(ls $FLAP_DIR)
do
    if [ -f $FLAP_DIR/$service/scripts/post_update.sh ]
    then
        $FLAP_DIR/$service/scripts/post_update.sh
    fi
done

manager setup cron
manager config generate

dc down
dc up
