#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	"")
		for check in "$FLAP_DIR"/system/cli/lib/health/*
		do
			echo "* [health] Checking $(basename "$check")"

			"$check" || true

		done
	;;
	summarize)
		echo "health | | Run some health check tests."
	;;
	help|*)
		echo "
$(flapctl health summarize)
Commands:
	'' | | Run some health check tests." | column -t -s "|"
	;;
esac
