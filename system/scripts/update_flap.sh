#!/bin/bash

set -e

git pull
git submodule update

# Run post update scripts for each services
for service in $(ls)
do
    if [ -f ./${service}/scripts/post_update.sh ]
    then
        ./${service}/scripts/post_update.sh
    fi
done

./setup_cron.sh

docker-compose down
docker-compose up
