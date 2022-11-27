#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	"")
		for check in "$FLAP_DIR"/system/cli/lib/checkup/*
		do
			echo "* [checkup] Checking $(basename "$check")"

			if ! "$check"
			then
				echo "[ERROR] $check failed."
			fi
		done
	;;
	summarize)
		echo "checkup | | Run some checkup check tests."
	;;
	help|*)
		echo "
$(flapctl checkup summarize)
Commands:
	'' | | Run some checkup check tests." | column -t -s "|"
	;;
esac
