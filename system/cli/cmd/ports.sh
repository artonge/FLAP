#!/bin/bash

set -e

CMD=$1
PORT=$2

case $CMD in
    open)
        # Delete port forwarding if any.
        upnpc -d $PORT TCP >> /dev/null || true

        {
            IP=$(upnpc -l | grep "Local LAN" | cut -d ' '  -f6)
            DESCRIPTION="Port forwarding for the FLAP box."

            # Create port mapping.
            upnpc -e "$DESCRIPTION" -a $IP $PORT $PORT TCP >> /dev/null
            echo "Port mapping created."
        } || { # Catch error
            echo "Failed to create port mapping."
        }
        ;;
    close)
        {
            # Delete port mapping
            upnpc -d $PORT TCP >> /dev/null
            echo "Port mapping deleted."
        } || { # Catch error
            echo "Failed to delete port mapping."
        }
        ;;
    list)
        # Grep only the list of port mapping
        upnpc -l | grep -E "^ [0-9]"
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
    list | | List port mappings." | column --table --separator "|"
        ;;
esac
