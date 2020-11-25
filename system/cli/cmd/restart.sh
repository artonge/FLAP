#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
        echo "restart | | Restart flap services."
    ;;
    help)
        echo "
$(flapctl restart summarize)
Commands:
    '' | | Restart flap services." | column -t -s "|"
    ;;
    "")
        echo "* [restart] Restarting services."
        flapctl stop
        flapctl start
    ;;
	handle_request)
		if [ ! -f "$FLAP_DATA/system/data/restart.txt" ]
		then
			exit 0
		fi

		type=$(cat "$FLAP_DATA/system/data/restart.txt")

		rm "$FLAP_DATA/system/data/restart.txt"

		case "$type" in
			"services")
				flapctl restart
			;;
			"host")
				reboot
			;;
		esac
	;;
	*)
		service=$CMD
		docker stop "flap_$service"
		docker rm "flap_$service"
		flapctl config generate_templates
		flapctl hooks generate_config "$service"
		docker-compose --no-ansi up --detach "$service"
	;;
esac
