#!/bin/bash

set -e

# Update env var
echo "export FLAP_DIR=/opt/flap" > /etc/environment
echo "export FLAP_DATA=/flap" >> /etc/environment
source /etc/environment

# Move flap directory
mv /flap $FLAP_DIR

# Update manager simlink
ln -sf $FLAP_DIR/system/cli/manager.sh /bin/manager

# Create data directory for each services
for service in $(ls -d $FLAP_DIR/*/)
do
    mkdir -p /flap/$(basename $service)
done

# Move system's data
if [ -d /var/lib/flap ]
then
    mv /var/lib/flap /flap/system/data
fi
