#!/bin/bash

set -euo pipefail

# v1.20.0

docker-compose --ansi never up --detach nextcloud

docker-compose exec -T --user www-data nextcloud php occ config:system:set appstoreenabled --value true --type boolean

if [ "${FLAG_NO_DOCUMENTSERVER:-false}" == "false" ]
then
	echo "* [10] Migrate from onlyoffice to collabora."
	echo "export ENABLE_COLLABORA=true" >> "$FLAP_DATA"/system/flapctl.env

	# shellcheck source=system/flapctl.examples.d/pipeline.env
	# shellcheck disable=SC1091
	source "$FLAP_DATA"/system/flapctl.env


	docker-compose exec -T --user www-data nextcloud php occ app:disable documentserver_community
	docker-compose exec -T --user www-data nextcloud php occ app:disable onlyoffice
fi

if [ "${ENABLE_COLLABORA:-false}" == "true" ]
then
	docker-compose exec -T --user www-data nextcloud php occ app:install richdocuments

	docker-compose exec -T --user www-data nextcloud php occ config:app:set richdocuments wopi_url --value "https://office.$PRIMARY_DOMAIN_NAME"
	docker-compose exec -T --user www-data nextcloud php occ config:app:set richdocuments public_wopi_url --value "https://office.$PRIMARY_DOMAIN_NAME"
	docker-compose exec -T --user www-data nextcloud php occ config:app:set richdocuments disable_certificate_verification --value "no"

	if [ "$PRIMARY_DOMAIN_NAME" == "flap.test" ]
	then
		docker-compose exec -T --user www-data nextcloud php occ --quiet config:app:set richdocuments disable_certificate_verification --value "yes"
	fi
fi

docker-compose --ansi never down