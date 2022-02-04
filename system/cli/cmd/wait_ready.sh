#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	summarize)
		echo "wait_ready | | Wait until services are up."
	;;
	help)
		echo "
$(flapctl wait_ready summarize)
Commands:
	| | Wait until all services are up." | column -t -s "|"
	;;
	""|*)
		services="${*:1}"
		services=${services:-$FLAP_SERVICES}

		for service in $services
		do
			if [ ! -f "$FLAP_DIR/$service/scripts/hooks/is_up.sh" ]
			then
				continue
			fi

			echo "* [wait_ready] Waiting for $service."

			i=0
			until "$FLAP_DIR/$service/scripts/hooks/is_up.sh"
			do
				i=$((i+1))
				if [ $((i % 10)) = 0 ] && [ "${FLAP_DEBUG:-}" = "true" ]
				then
					docker-compose ps
					yq -r '.services | keys[]' "$FLAP_DIR/$service/docker-compose.yml" | xargs -I {} docker-compose logs {}
				fi

				debug "$service is unavailable - waiting (attempt #$i)."
				sleep 1
			done
		done
	;;
esac
