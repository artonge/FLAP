#!/bin/bash

# Example: ./reset_local_install.sh

set -eux

sudo -E flapctl stop
sudo -E flapctl clean data -y

sudo mkdir --parents "$FLAP_DATA/system"
sudo cp "$FLAP_DIR/system/flapctl.examples.d/local.env" "$FLAP_DATA/system/flapctl.env"

sudo -E flapctl start

sudo -E flapctl users create_admin
sudo -E flapctl tls generate_localhost
sudo -E flapctl restart
sudo -E flapctl hooks post_domain_update

sudo -E docker exec --user www-data flap_nextcloud php occ user:list
sudo -E docker exec flap_sogo sogo-tool create-folder theadmin Calendar TestCalendar

sudo -E flapctl backup
