#!/bin/bash

set -euo pipefail

exit_code=0

for port in $NEEDED_PORTS
do
	port=$(echo "$port" | cut -d '/' -f1)

	ss="$(ss --listening --processes --numeric --tcp --udp --no-header "( sport = $port )")"

	if [ "$ss" != "" ]
	then
		pid="$(echo "$ss" | grep -oE 'pid=[0-9]+' | head -1 | cut -d '=' -f2)"
		program="$(ps -p "$pid" -o comm=)"

		if [ "$program" != "docker-proxy" ] && [ "$program" != "sshd" ]
		then
			echo "	- Port $port is already in use by $program."
			exit_code=1
		fi
	fi
done

exit "$exit_code"