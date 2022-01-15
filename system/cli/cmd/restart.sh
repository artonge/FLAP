#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	summarize)
        echo "restart | | Restart flap services."
		echo "restart | <service> [<service> ...] | Restart specific services. Will generate template and run generate_config hooks."
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
		# Get services list from args.
		services=("${@:1}")

		flapctl stop "${services[@]}"
		flapctl start "${services[@]}"
	;;
esac
