#!/bin/bash

set -ue

exit_code=0

CMD=${1:-}
ARGS=("$@")
ARGS=("${ARGS[@]:1}")


export FLAP_LIBS
FLAP_LIBS="$FLAP_DIR/system/cli/lib"


# Load helpers functions.
# shellcheck source=system/cli/lib/helpers.sh
source "$FLAP_LIBS/helpers.sh"

# Check for flapctl.env file.
if [ ! -f "$FLAP_DATA/system/flapctl.env" ]
then
	echo "* [flapctl] flapctl.env file not found, create one and retry."
fi

# Load feature flags and services environment variables.
# shellcheck source=system/cli/lib/load_env_vars.sh
source "$FLAP_LIBS/load_env_vars.sh"


# Execute the $CMD.
if [ -f "$FLAP_DIR/system/cli/cmd/$CMD.sh" ]
then
	# Choose color from the depth of the flapctl call.
	# test "k" == "ok" || echo "[FRAME:DEBUG] flapctl:pstree"; exit 1
	child_nb=$(pstree -ls 9999999 | grep -o '\<flapctl\>' | wc -l)
	(( "i=29 + $child_nb" ))
	OLD_GREP_COLOR=${GREP_COLOR:-"1;$i"}

	# Prevent flapctl calls when an update is ongoing.
	if [ "$child_nb" == 2 ] && [ -f /tmp/updating_flap.lock ]
	then
		pid=$(cat /tmp/updating_flap.lock)

		# Check process is still running.
		if kill -0 "$pid"
		then
			echo "* [flapctl] Ongoing update, exiting."
			exit 0
		else
			rm /tmp/updating_flap.lock
		fi
	fi

	# Highlight FLAP's logs with grep.
	export GREP_COLOR="1;$i"

	# --line-buffered allow grep line by line output instead of grep using a larger buffer.
	# --color=always allow for the color not to be overrided.
	"$FLAP_DIR/system/cli/cmd/$CMD.sh" "${ARGS[@]}" 2> /dev/stdout | \
		sed --unbuffered -E "s/\* \[([a-z:]+)\]/\* \[$CMD:\1\]/" | \
		grep --line-buffered --color=always -E "^\* \[.+\].*|$" | \
		cat
	exit_code=${PIPESTATUS[0]}

	# Restore GREP_COLOR.
	export GREP_COLOR=$OLD_GREP_COLOR
else
	# Show the help if the command is not found.
	"$FLAP_DIR/system/cli/cmd/help.sh" "${ARGS[@]}"
fi

# Display "ERROR" when the cmd returned an error.
if [ "$exit_code" != 0 ]
then
	echo "* [$CMD] ERROR"
	exit "$exit_code"
fi
