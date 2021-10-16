#!/bin/bash

set -eu

# v1.20.0

if [ "${FLAG_NO_DOCUMENTSERVER:-false}" == "false" ]
then
	echo "* [10] Migrate from onlyoffice to collabora."
	echo "export ENABLE_COLLABORA=true" >> "$FLAP_DATA"/system/flapctl.env

	docker-compose --no-ansi up --detach nextcloud

	docker-compose exec -T --user www-data nextcloud php occ app:disable documentserver_community
	docker-compose exec -T --user www-data nextcloud php occ app:disable onlyoffice

	docker-compose exec -T --user www-data nextcloud php occ app:install richdocuments

	php occ --quiet config:app:set richdocuments wopi_url --value "https://office.$PRIMARY_DOMAIN_NAME"
	php occ --quiet config:app:set richdocuments public_wopi_url --value "https://office.$PRIMARY_DOMAIN_NAME"
	php occ --quiet config:app:set richdocuments disable_certificate_verification --value "no"

	if [ "$PRIMARY_DOMAIN_NAME" == "flap.test" ]
	then
		php occ --quiet config:app:set richdocuments disable_certificate_verification --value "yes"
	fi

	docker-compose --no-ansi down
fi