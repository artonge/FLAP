#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	summarize)
		echo "stop | [<service-name> ...] | Stop flap services."
	;;
	help)
		echo "
$(flapctl stop summarize)
Commands:
	[<service-name> ...] | | Stop the given services, or stop them all if nothing is provided." | column -t -s "|"
	;;
	"")
		# Go to FLAP_DIR for docker compose.
		cd "$FLAP_DIR"

		# Stop all services and grep-out output. If an error occurs:
		# - regenerate the config and retry.
		# - if it still persist, restart the docker daemon and retry.
		echo '* [stop] Stopping services.'
		{
			if [ "${FLAP_DEBUG:-}" == "true" ]
			then
				docker compose --ansi never down --remove-orphans
			else
				docker compose --ansi never down --remove-orphans 2> /dev/stdout | { grep -v -E '^(Stopping)|^(Removing)|(not found\.)$' || true; }
			fi
		} || {
			# shellcheck disable=SC2016
			sleep 10 &&
			flapctl config generate &&
			docker compose ps &&
			docker ps -a &&
			docker network ls &&
			docker volume ls &&
			docker network ls --format '{{ .Name }}' | xargs --verbose -I{} docker network inspect --format "{{range \$cid,\$v := .Containers}}{{printf \"%s: %s\n\" \$cid \$v.Name}}{{end}}" {} &&
			docker compose down --remove-orphans
		} || {
			systemctl restart docker &&
			docker compose down --remove-orphans
		}
		;;
	*)
		# Get services list from args.
		services=("${@:1}")
		services_list=()

		sub_services=()
		for service in "${services[@]}"
		do
			mapfile -t tmp_services < <(yq -r '.services | keys[]' "$FLAP_DIR/$service/docker-compose.yml");
			sub_services+=("${tmp_services[@]}")
		done

		for service in "${sub_services[@]}"
		do
			if docker ps --format '{{.Names}}' | grep -E "flap_$service$"
			then
				services_list+=("flap_$service")
			fi
		done

		if [ "${#services_list[@]}" != "0" ]
		then
			docker stop "${services_list[@]}"
			docker rm "${services_list[@]}"
		fi
	;;
esac
