#!/bin/bash

set -euo pipefail

echo "* [3] Move nextcloud_db_password file."
mkdir --parents "$FLAP_DATA/nextcloud/passwd"
if [ -f "$FLAP_DATA/system/data/nextcloudDbPwd.txt" ]
then
	mv "$FLAP_DATA/system/data/nextcloudDbPwd.txt" "$FLAP_DATA/nextcloud/passwd/nextcloud_db_pwd.txt"
fi

if [ "$ARCH" == "x86_64" ]
then
	echo "* [3] Install Onlyoffice."
	docker-compose --no-ansi up --detach nextcloud

	flapctl hooks wait_ready nextcloud

	docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value true --type boolean

	docker exec --user www-data flap_nextcloud php occ app:install documentserver_community || true
	docker exec --user www-data flap_nextcloud php occ app:install onlyoffice || true

	docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value false --type boolean

	docker-compose --no-ansi down
fi
