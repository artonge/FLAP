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

# Show the help if the command is not found.
if [ ! -f "$FLAP_DIR/system/cli/cmd/$CMD.sh" ]
then
	"$FLAP_DIR/system/cli/cmd/help.sh" "${ARGS[@]}"
fi

# Choose color from the depth of the flapctl call.
child_nb=$(pgrep flapctl -g 0 -c)
(( "i=30 + $child_nb" ))
OLD_GREP_COLOR=${GREP_COLOR:-"1;$i"}

# Highlight FLAP's logs with grep.
export GREP_COLOR="1;$i"

# Prevent synchronous flapctl calls.
if [ "$child_nb" == 1 ]
then
	# https://www.putorius.net/lock-files-bash-scripts.html
	exec 100>/tmp/flap.lock || exit 1
	flock -w 30 100 || exit 1
fi

# Execute the $CMD.
# --line-buffered allow grep line by line output instead of grep using a larger buffer.
# --color=always allow for the color not to be overrided.
"$FLAP_DIR/system/cli/cmd/$CMD.sh" "${ARGS[@]}" 2> /dev/stdout | \
	sed --unbuffered -E "s/\* \[([a-z:]+)\]/\* \[$CMD:\1\]/" | \
	grep --line-buffered --color=always -E "^\* \[.+\].*|$" | \
	cat
exit_code=${PIPESTATUS[0]}

# Restore GREP_COLOR.
export GREP_COLOR=$OLD_GREP_COLOR

# Display "ERROR" when the cmd returned an error.
if [ "$exit_code" != 0 ]
then
	echo "* [$CMD] ERROR"
	exit "$exit_code"
fi
