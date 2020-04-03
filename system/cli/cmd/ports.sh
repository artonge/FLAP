#!/bin/bash

set -eu

CMD=${1:-}
PORT=${2:-}
PROTOCOL=$(echo "${3:-TCP}" | tr '[:lower:]' '[:upper:]')
DESCRIPTION="Port forwarding for the FLAP box."

case $CMD in
    open)
        # Delete port forwarding if any.
        flapctl ports close "$PORT" > /dev/null || true

        {
            # Get the internal network IP
            IP=$(flapctl ip internal) &&

            # Create port mapping.
            upnpc -e "$DESCRIPTION" -a "$IP" "$PORT" "$PORT" "$PROTOCOL" > /dev/null &&

            # Check that port mapping exists
            flapctl ports list | grep "$IP:$PORT" > /dev/null &&

            echo "* [ports] Port mapping created ($PORT)."
        } || { # Catch error
            echo "* [ports] Failed to create port mapping ($PORT)."
            exit 1
        }
        ;;
    close)
        # Delete port mapping.
        upnpc -d "$PORT" "$PROTOCOL" > /dev/null || true

        {
            # Check that port mapping do not exist
            (flapctl ports list) | grep -v ":$PORT" > /dev/null &&
            echo "* [ports] Port mapping deleted ($PORT)."
        } || { # Catch error
            echo "* [ports] Failed to delete port mapping ($PORT)."
            exit 1
        }
        ;;
    list)
        upnpc -l | grep -E "^ [0-9]" | cat
        ;;
    summarize)
        echo "ports | [open, close, list, help] | Manipulate ports forwarding."
        ;;
    help|*)
        printf "
ports | Manipulate ports forwarding.
Commands:
    open | [port] | Open a port.
    close | [port] | Close a port.
    list | | List port mappings." | column -t -s "|"
        ;;
esac
