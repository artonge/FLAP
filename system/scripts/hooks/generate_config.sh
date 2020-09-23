#!/bin/bash

set -eu

echo 'Generating docker-compose.yml...'

# Delete override so it is not kept after disabling FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE.
rm --force "$FLAP_DIR/docker-compose.override.yml"

main_compose_file="$FLAP_DIR/docker-compose.yml"
main_compose_override_file="$FLAP_DIR/docker-compose.override.yml"

# Get list of docker-compose files.
mapfile -t compose_files < <(find "$FLAP_DIR" -maxdepth 2 -mindepth 2 -name docker-compose.yml)
mapfile -t compose_monitoring_files < <(find "$FLAP_DIR" -maxdepth 2 -mindepth 2 -name docker-compose.monitoring.yml)
mapfile -t compose_override_files < <(find "$FLAP_DIR" -maxdepth 2 -mindepth 2 -name docker-compose.override.yml)
mapfile -t compose_ci_files < <(find "$FLAP_DIR" -maxdepth 2 -mindepth 2 -name docker-compose.ci.yml)

echo "Merge services' docker-compose.yml files."
# shellcheck disable=SC2016
yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	'reduce .[] as $service ({}; . * $service)' "${compose_files[@]}" > "$main_compose_file.tmp"

echo "Merge services' nginx-extra-volumes properties."
# shellcheck disable=SC2016
nginx_volumes=$(
	yq \
		--slurp \
		'reduce .[] as $service ([]; . + $service["x-nginx-extra-volumes"])' \
		"${compose_files[@]}"
)

echo "Insert nginx-extra-volumes into final the docker-compose.yml file."
# shellcheck disable=SC2016
yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	--argjson volumes "$nginx_volumes" \
	'.[0] * {"services": {"nginx": {"volumes": (.[0].services.nginx.volumes + $volumes)}}}' \
	"$main_compose_file.tmp" > "$main_compose_file"


if [ "${ENABLE_MONITORING:-}" == "true" ]
then
	echo "Merge services' docker-compose.monitoring files."
	# shellcheck disable=SC2016
	yq \
		--yaml-output \
		--yaml-roundtrip \
		--slurp \
		'reduce .[] as $service ({}; . * $service)' "${compose_monitoring_files[@]}" "$main_compose_file" > "$main_compose_file.tmp"

	cat "$main_compose_file.tmp" > "$main_compose_file"
fi


if [ "${FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE:-}" == "true" ]
then
	echo "Merge services' docker-compose.override files."
	# shellcheck disable=SC2016
	yq \
		--yaml-output \
		--yaml-roundtrip \
		--slurp \
		'reduce .[] as $service ({}; . * $service)' "${compose_override_files[@]}" > "$main_compose_override_file"
fi


if [ "${FLAG_GENERATE_DOCKER_COMPOSE_CI:-}" == "true" ]
then
	echo "Merge services' docker-compose.ci.yml files."
	touch "$main_compose_override_file"
	# shellcheck disable=SC2016
	yq \
		--yaml-output \
		--yaml-roundtrip \
		--slurp \
		'reduce .[] as $service ({}; . * $service)' "$main_compose_override_file" "${compose_ci_files[@]}" > "$main_compose_override_file.tmp"

	cat "$main_compose_override_file.tmp" >> "$main_compose_override_file"
fi

rm --force "$main_compose_override_file.tmp"
rm --force "$main_compose_file.tmp"
