#!/bin/bash

set -e

CMD=$1
PORT=$2
DESCRIPTION="Port forwarding for the FLAP box."

case $CMD in
    open)
        {
            # Delete port forwarding if any.
            manager ports close $PORT >> /dev/null

            # Get the internal network IP
            IP=$(manager ip internal)

            # Create port mapping.
            upnpc -e "$DESCRIPTION" -a $IP $PORT $PORT TCP >> /dev/null
            echo "Port mapping created ($PORT)."
        } || { # Catch error
            echo "Failed to create port mapping ($PORT)."
        }
        ;;
    close)
        {
            # Delete port mapping
            upnpc -d $PORT TCP >> /dev/null
            echo "Port mapping deleted ($PORT)."
        } || { # Catch error
            echo "Failed to delete port mapping ($PORT)."
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
