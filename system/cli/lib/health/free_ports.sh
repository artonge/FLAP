#!/bin/bash

set -eu

exit_code=0

for port in $NEEDED_PORTS
do
	port=$(echo "$port" | cut -d '/' -f1)

	if [ "$(ss -tulpn | grep "$port")" != "" ]
	then
		echo "- Port $port is already in use."
		exit_code=1
	fi
done

exit "$exit_code"