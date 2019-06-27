#!/bin/bash

set -e

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
if [ -z ${CI+x} ]
then
    # Set local domain name to flap.local
    hostname flap

    # Create port mappings
    manager ports open 80
    manager ports open 443
fi

# Run post setup scripts for each services
manager hooks post_install

touch /flap/system/data/installation_done.txt
