#!/bin/bash

set -e

################################################################################
echo "SETTING UP DIRECTORIES"
# Create data directory for each services
# And set current_migration.txt
for service in $(ls -d $FLAP_DIR/*/)
do
    mkdir -p $FLAP_DATA/$(basename $service)
    cat $FLAP_DIR/$(basename $service)/scripts/migrations/base_migration.txt > $FLAP_DATA/$(basename $service)/current_migration.txt
done

# Create log folder
mkdir -p /var/log/flap

################################################################################
echo "STARTING FLAP"
# Go to FLAP_DIR for docker-compose
cd $FLAP_DIR

# Execute configuration actions with the manager.
manager setup cron
manager tls generate_local
manager config generate

# Start all services
docker-compose up -d

# Prevent network operations during CI.
if [ ! $CI ]
then
    # Set local domain name to flap.local
    hostname flap

    # Create port mappings
    manager ports open 80
    manager ports open 443
fi

# Run post setup scripts for each services
manager hooks post_install

# Mark installation as done
touch /flap/system/data/installation_done.txt
