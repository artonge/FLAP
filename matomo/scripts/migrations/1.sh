#!/bin/bash

set -eu

# Version v1.14.2

echo "* [1] Start matomo."
docker-compose run --name migrate_matomo --detach matomo

echo "* [1] Fix email encryption setting."
docker exec migrate_matomo php /var/www/html/console config:set --section="mail" --key="encryption" --value="tls"

echo "* [1] Update matomo."
docker exec --user root migrate_matomo apt update
docker exec --user root migrate_matomo apt install -y rsync
docker exec migrate_matomo rsync \
	--delete \
	--archive \
	--exclude "/plugins/" \
	--exclude "/config/config.ini.php" \
	/usr/src/matomo/ /var/www/html

docker exec migrate_matomo php /var/www/html/console core:update

echo "* [1] Migrate database to utf8mb4."
docker exec migrate_matomo php /var/www/html/console core:convert-to-utf8mb4

echo "* [1] Stop ldap and mariadb."
docker-compose down
