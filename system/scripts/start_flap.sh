#!/bin/bash

set -e

################################################################################
echo "STARTING FLAP"
# Go to FLAP_DIR for docker-compose
cd $FLAP_DIR

# Prevent network operations during CI.
if [ "$CI" != "" ]
then
    # Set local domain name to flap.local
    hostname flap

    # Create port mappings
    manager ports open 80
    manager ports open 443
fi

# Start all services
docker-compose up -d

# Run post setup scripts for each services
manager hooks post_install
