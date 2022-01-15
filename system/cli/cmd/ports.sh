#!/bin/bash

set -euo pipefail

CMD=${1:-}
PORT=${2:-}
PROTOCOL=$(echo "${3:-TCP}" | tr '[:lower:]' '[:upper:]')
DESCRIPTION="Port forwarding for the FLAP box."

case $CMD in
	setup)
		# Exit now if feature is disabled.
		if [ "${FLAG_NO_NAT_NETWORK_SETUP:-}" == "true" ]
		then
			exit 0
		fi

		ip=$(flapctl ip internal)
		open_ports=$(flapctl ports list)

		# Open ports.
		for port in $NEEDED_PORTS
		do
			protocol=$(echo "$port" | cut -d '/' -f2 | tr '[:lower:]' '[:upper:]')
			port=$(echo "$port" | cut -d '/' -f1)

			if echo "$open_ports" | grep "$protocol" | grep "$ip:$port" > /dev/null
			then
				continue
			fi

			flapctl ports open "$port" "$protocol" "$ip"
		done
		;;
	open)
		debug "Opening port $PORT/$PROTOCOL"

		IP=${4:-$(flapctl ip internal)}

		# Delete port forwarding if any.
		flapctl ports close "$PORT" > /dev/null

		{
			# Create port mapping.
			upnpc -e "$DESCRIPTION" -a "$IP" "$PORT" "$PORT" "$PROTOCOL" > /dev/null &&

			debug "* [ports] Port mapping created ($PORT)."
		} || { # Catch error
			debug "* [ports] Failed to create port mapping ($PORT)."
			exit 1
		}
		;;
	close)
		debug "Closing port $PORT/$PROTOCOL"

		{
			# Delete port mapping.
			upnpc -d "$PORT" "$PROTOCOL" > /dev/null &&
			debug "* [ports] Port mapping deleted ($PORT)."
		} || { # Catch error
			debug "* [ports] Failed to delete port mapping ($PORT)."
			exit 1
		}
		;;
	list)
		upnpc -l | grep -E "^ *[0-9]{1,2}" | cat
		;;
	summarize)
		echo "ports | [open, close, list, help] | Manipulate ports forwarding."
		;;
	help|*)
		printf "
ports | Manipulate ports forwarding.
Commands:
	open | [port] | Open a port.
	close | [port] | Close a port.
	list | | List port mappings." | column -t -s "|"
		;;
esac
