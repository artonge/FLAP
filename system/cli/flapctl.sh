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


# Load feature flags and services environment variables.
# shellcheck source=system/cli/lib/load_env_vars.sh
source "$FLAP_LIBS/load_env_vars.sh"


# Execute the $CMD.
if [ -f "$FLAP_DIR/system/cli/cmd/$CMD.sh" ]
then
	# Choose color from the depth of the flapctl call.
	(( "i=29 + $(pstree -ls $$ | grep -o '\<flapctl\>' | wc -l)" ))
	OLD_GREP_COLOR=${GREP_COLOR:-"1;$i"}

	# Highlight FLAP's logs with grep.
	export GREP_COLOR="1;$i"

	# --line-buffered allow grep line by line output instead of grep using a larger buffer.
	# --color=always allow for the color not to be overrided.
	"$FLAP_DIR/system/cli/cmd/$CMD.sh" "${ARGS[@]}" &> /dev/stdout | \
		sed --unbuffered -E "s/\[([a-z:]+)\]/\[$CMD:\1\]/" | \
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
