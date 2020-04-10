#!/bin/bash

set -eu

CMD=${1:-}

# Disable ufw to allow upnp to work.
if [ "${FLAG_NO_FIREWALL_SETUP:-}" != "true" ]
then
	ufw --force disable > /dev/null
fi

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

if [ "${FLAG_NO_FIREWALL_SETUP:-}" != "true" ]
then
	ufw --force enable > /dev/null
fi
