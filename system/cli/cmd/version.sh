#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	summarize)
		echo "ip | [internal, external, help] | Get ip address."
		;;
	help)
		echo "
$(flapctl version summarize)
Commands:
	"" | | Show the current version of flap." | column -t -s "|"
		;;
	*)
		git describe --tags --abbrev=0
		;;
esac
