#!/bin/bash

set -eu

echo "* [3] Move nextcloud_db_password file."
mkdir --parents "$FLAP_DATA/nextcloud/passwd"
mv "$FLAP_DATA/system/data/nextcloudDbPwd.txt" "$FLAP_DATA/nextcloud/passwd/nextcloud_db_pwd.txt"

if [ "$ARCH" == "x86_64" ]
then
	echo "* [3] Install Onlyoffice."
	docker-compose --no-ansi up --detach nextcloud

	"$FLAP_DIR/nextcloud/scripts/wait_ready.sh"

	php occ app:install documentserver_community || true
	php occ app:install onlyoffice || true

	docker-compose --no-ansi down
fi
