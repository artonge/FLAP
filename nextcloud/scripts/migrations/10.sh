#!/bin/bash

set -eu

# v1.15.0

if [ "${FLAG_NO_DOCUMENTSERVER:-false}" == "true" ]
then
	echo "* [10] Migrate from onlyoffice to collabora."
	echo "export ENABLE_COLLABORA=true" >> "$FLAP_DATA"/system/flapctl.env

	docker-compose --no-ansi up --detach nextcloud

	docker-compose exec -T --user www-data nextcloud php occ app:disable documentserver_community
	docker-compose exec -T --user www-data nextcloud php occ app:disable onlyoffice

	flapctl hooks post_install nextcloud
	flapctl hooks post_update nextcloud

	docker-compose --no-ansi down
fi