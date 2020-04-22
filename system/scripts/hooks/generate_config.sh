#!/bin/bash

set -eu

echo 'Generate docker-compose.yml.'

cat "$FLAP_DIR/system/docker-compose.yml" > "$FLAP_DIR/docker-compose.yml"

rm -f "$FLAP_DIR/docker-compose.override.yml"

if [ "${FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE:-}" == "true" ] || [ "${FLAG_GENERATE_DOCKER_COMPOSE_CI:-}" == "true" ]
then
	cat "$FLAP_DIR/system/docker-compose.override.yml" > "$FLAP_DIR/docker-compose.override.yml"
fi

for service in $FLAP_SERVICES
do
	# Check if docker-compose.yml exists for the service.
	if [ -f "$FLAP_DIR/$service/docker-compose.yml" ]
	then
		echo - "$service"

		# Merge service's compose file into the main compose file.
		"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
			"$FLAP_DIR/docker-compose.yml" \
			"$FLAP_DIR/$service/docker-compose.yml"
	fi

	# Check if docker-compose.override.yml exists for the service.
	if [ -f "$FLAP_DIR/$service/docker-compose.override.yml" ]
	then
		if [ "${FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE:-}" == "true" ]
		then
			# Merge service's compose file into the main compose file.
			"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
				"$FLAP_DIR/docker-compose.override.yml" \
				"$FLAP_DIR/$service/docker-compose.override.yml"
		fi
	fi

	# Check if docker-compose.local.yml exists for the service.
	if [ -f "$FLAP_DIR/$service/docker-compose.ci.yml" ]
	then
		if [ "${FLAG_GENERATE_DOCKER_COMPOSE_CI:-}" == "true" ]
		then
			# Merge service's compose file into the main compose file.
			"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
				"$FLAP_DIR/docker-compose.override.yml" \
				"$FLAP_DIR/$service/docker-compose.ci.yml"
		fi
	fi
done
