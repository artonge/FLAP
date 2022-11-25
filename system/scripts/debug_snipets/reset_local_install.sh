#!/bin/bash

# Example: ./reset_local_install.sh

set -euo pipefail

# Guard to prevent executing this file on a real instance.
if [ "$(cat "$FLAP_DATA/system/data/primary_domain.txt")" != "flap.test" ] && [ -f "$FLAP_DATA/system/data/installation_done.txt" ]
then
	echo "WARNING: Instance is not using flap.test. Are you on a live instance ?"
	exit 0
fi

sudo -E flapctl stop
sudo -E flapctl clean data -y

sudo mkdir --parents "$FLAP_DATA/system"
sudo cp "$FLAP_DIR/system/flapctl.examples.d/local.env" "$FLAP_DATA/system/flapctl.env"

sudo -E flapctl start

sudo -E flapctl users create_admin
sudo -E flapctl domains generate_local

sudo -E flapctl backup
