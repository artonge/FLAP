#!/bin/bash

set -ue

# generatePassword <service> <var_name>
# Will store a password in a file in the service's `passwd` directory.
generatePassword() {
	if [ ! -f "$FLAP_DATA/$1/passwd/$2.txt" ]
	then
		mkdir --parents "$FLAP_DATA/$1/passwd"
		openssl rand --hex 32 > "$FLAP_DATA/$1/passwd/$2.txt"
	fi

	cat "$FLAP_DATA/$1/passwd/$2.txt"
}
export -f generatePassword

debug() {
	if "${FLAP_DEBUG:-false}"
	then
		echo "$1"
	fi
}

export -f debug
