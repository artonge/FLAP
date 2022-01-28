#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	internal)
		upnpc -l | grep "Local LAN" | cut -d ' ' -f6
		;;
	external)
		{
			# Try to get the external IP with upnpc if we are behind a NAT.
			upnpc -l 2> /dev/stdout | grep "ExternalIPAddress" | cut -d ' ' -f3
		} || {
			# Default to icanhazip.com if upnpc does not work.
			curl -4 --silent https://icanhazip.com
		}
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
