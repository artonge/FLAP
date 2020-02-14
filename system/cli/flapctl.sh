#!/bin/bash

set -ue

exit_code=0

CMD=${1:-}
ARGS=("$@")
ARGS=("${ARGS[@]:1}")

# Read password from file.
# If the file does not exists, create it and generate a password.
readPwd() {
    mkdir -p "$FLAP_DATA/system/data"

    if [ ! -f "$1" ]
    then
        openssl rand --hex 32 > "$1"
    fi

    cat "$1"
}

# Export env var.
PRIMARY_DOMAIN_NAME=$("$FLAP_DIR/system/cli/lib/tls/show_primary_domain.sh")
export PRIMARY_DOMAIN_NAME
DOMAIN_NAMES=$("$FLAP_DIR/system/cli/lib/tls/list_domains.sh" | grep OK | cut -d ' ' -f1 | paste -sd " " -)
export DOMAIN_NAMES
SECONDARY_DOMAIN_NAMES="${DOMAIN_NAMES//${PRIMARY_DOMAIN_NAME:-"none"}/}"
export SECONDARY_DOMAIN_NAMES
export SUBDOMAINS="auth files mail"

# Read passwords from files
ADMIN_PWD=$(readPwd "$FLAP_DATA/system/data/adminPwd.txt")
export ADMIN_PWD
SOGO_DB_PWD=$(readPwd "$FLAP_DATA/system/data/sogoDbPwd.txt")
export SOGO_DB_PWD
NEXTCLOUD_DB_PWD=$(readPwd "$FLAP_DATA/system/data/nextcloudDbPwd.txt")
export NEXTCLOUD_DB_PWD


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
    "$FLAP_DIR/system/cli/cmd/help.sh" "${ARGS[@]}"
fi

# Display "ERROR" when the cmd returned an error.
if [ "$exit_code" != 0 ]
then
    echo "* [$CMD] ERROR"
    exit "$exit_code"
fi
