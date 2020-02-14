#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
		echo "help | | Show help."
		;;
	help|*)
		echo "Commands:"

		help_string=""

		for cmd in "$FLAP_DIR"/system/cli/cmd/*
		do
			help_string+="  $("$cmd" summarize)"$'\n'
		done
		echo "$help_string" | column -t -s "|"
		;;
esac
