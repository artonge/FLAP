#!/bin/bash

set -ue

exit_code=0

CMD=${1:-}
ARGS=("$@")
ARGS=("${ARGS[@]:1}")

# Load feature flags.
if [ -f "$FLAP_DIR/flapctl.env" ]
then
	# shellcheck source=flapctl.env
	# shellcheck disable=SC1091
	source "$FLAP_DIR/flapctl.env"
fi

# Read password from file.
# If the file does not exists, create it and generate a password.
readPwd() {
    mkdir --parents "$FLAP_DATA/system/data"

    if [ ! -f "$1" ]
    then
        openssl rand --hex 32 > "$1"
    fi

    cat "$1"
}

# generatePassword <service> <var_name>
# Will store a password in a file in the service's `passwd` directory.
generatePassword() {
	if [ ! -f "$FLAP_DATA/$1/passwd/$2.txt" ]
	then
		echo "Generate $2 for $1."
		mkdir --parents "$FLAP_DATA/$1/passwd"
		openssl rand --hex 32 > "$FLAP_DATA/$1/passwd/$2.txt"
	fi

	cat "$FLAP_DATA/$1/passwd/$2.txt"
}
export -f generatePassword

FLAP_LIBS="$FLAP_DIR/system/cli/lib"

# Export the ARCH env var.
export ARCH
ARCH=$(uname -m)

# Export env var.
export PRIMARY_DOMAIN_NAME
export DOMAIN_NAMES
export SECONDARY_DOMAIN_NAMES
export SUBDOMAINS

# System
# 22 - SSH

# Nginx.
# 80 - HTTP
# 443 - HTTPS

# Mail.
# 25 - SMTP
# 587 - SMTP with STARTLS
# 143 - IMAP
export NEEDED_PORTS="22/tcp 80/tcp 443/tcp 25/tcp 587/tcp 143/tcp"

PRIMARY_DOMAIN_NAME=$("$FLAP_LIBS/tls/show_primary_domain.sh")
DOMAIN_NAMES=$("$FLAP_LIBS/tls/list_domains.sh" | grep OK | cut -d ' ' -f1 | paste -sd " " -)
SECONDARY_DOMAIN_NAMES="${DOMAIN_NAMES//${PRIMARY_DOMAIN_NAME:-"none"}/}"
SUBDOMAINS="auth mail"

# Read passwords from files.
export ADMIN_PWD
ADMIN_PWD=$(readPwd "$FLAP_DATA/system/data/adminPwd.txt")

export SOGO_DB_PWD
SOGO_DB_PWD=$(readPwd "$FLAP_DATA/system/data/sogoDbPwd.txt")

# Load services env vars.
export FLAP_ENV_VARS
FLAP_ENV_VARS="\${ARCH} \${PRIMARY_DOMAIN_NAME} \${SECONDARY_DOMAIN_NAMES} \${DOMAIN_NAMES} \${ADMIN_PWD} \${SOGO_DB_PWD}"

# Load services environement variables.
# This will populate FLAP_ENV_VARS and SUBDOMAINES.
for service in "$FLAP_DIR"/*
do
	if [ ! -f "$service/scripts/hooks/load_env.sh" ]
	then
		continue
	fi

	# shellcheck source=jitsi/scripts/hooks/load_env.sh
	source "$service/scripts/hooks/load_env.sh"
done

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
