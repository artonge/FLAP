#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
		echo "exec | <script_name> | Execute a script inside a service's scripts folder."
	;;
	help)
		flapctl exec summarize
	;;
	*)
		service=${1}
		script_name=${2}

		"$FLAP_DIR/$service/scripts/$script_name.sh"
	;;
esac
