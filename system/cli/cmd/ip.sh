#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	internal)
		upnpc -l | grep "Local LAN" | cut -d ' '  -f6
		;;
	external)
		if [ "${FLAG_USE_FIXED_IP:-}" == "true" ]
		then
			cat "$FLAP_DATA/system/data/fixed_ip.txt"
		else
			upnpc -l | grep "ExternalIPAddress" | cut -d ' '  -f3
		fi
		;;
	dns)
		host -t A "$2" | cut -d ' '  -f4
		;;
	setup)
		if [ "${FLAG_USE_FIXED_IP:-}" != "true" ]
		then
			echo "* [setup:FEATURE_FLAG] Skip fixed IP setup."
			exit 0
		fi

		echo "* [setup] Setting static IP"
		mkdir --parents "$FLAP_DATA/system/data"
		curl -4 https://icanhazip.com 2>/dev/null > "$FLAP_DATA/system/data/fixed_ip.txt"
		echo "Static IP is $(cat "$FLAP_DATA/system/data/fixed_ip.txt")"
		;;
	summarize)
		echo "ip | [internal, external, help] | Get ip address."
		;;
	help|*)
		echo "
$(flapctl ip summarize)
Commands:
	internal | | Show the internal ip.
	external | | Show the external ip.
	dns | <domain_name> | Ask the ip for a given domain name." | column -t -s "|"
		;;
esac
