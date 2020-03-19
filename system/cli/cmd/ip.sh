#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	internal)
		upnpc -l | grep "Local LAN" | cut -d ' '  -f6
		;;
	external)
		if "${FLAG_USE_FIXED_IP:-}" == "true"
		then
			cat "$FLAP_DATA/system/data/fixed_ip.txt"
		else
			upnpc -l | grep "ExternalIPAddress" | cut -d ' '  -f3
		fi
		;;
	summarize)
		echo "ip | [internal, external, help] | Get ip address."
		;;
	help|*)
		echo "
$(flapctl ip summarize)
Commands:
	internal | | Show the internal ip.
	external | | Show the external ip." | column -t -s "|"
		;;
esac
