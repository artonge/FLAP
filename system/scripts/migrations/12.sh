#!/bin/bash

set -euo pipefail

echo "* [12] Move admin_pwd file."
mkdir --parents "$FLAP_DATA/system/passwd"
mv "$FLAP_DATA/system/data/adminPwd.txt" "$FLAP_DATA/system/passwd/admin_pwd.txt"

echo "* [12] Create flapctl.env if missing."
touch "$FLAP_DIR/flapctl.env"

echo "* [12] Migrate environment variables."
if [ "${FLAG_NO_RAID_SETUP:-}" == "true" ]
then
	sed 's/FLAG_NO_RAID_SETUP/FLAG_DISK_MODE_SINGLE/g' "$FLAP_DIR/flapctl.env"
else
	echo "export FLAG_DISK_MODE_RAID1=true" >> "$FLAP_DIR/flapctl.env"
fi

echo "* [12] Move flapctl.env to the data directory."
mv "$FLAP_DIR/flapctl.env" "$FLAP_DATA/system/flapctl.env"

echo "* [12] Mark all enabled services as installed."
for service in $FLAP_SERVICES
do
	echo "* [8] Marking $service as installed."
	touch "$FLAP_DATA/$service/installed.txt"
done

echo "* [12] Reconfigure firewall."
flapctl setup firewall
