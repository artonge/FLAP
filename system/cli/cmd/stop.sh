#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        # Go to FLAP_DIR for docker-compose.
        cd $FLAP_DIR

        # Generate configuration so docker-compose does not complains because of a missing config file.
        manager config generate

        # Start all services.
        echo '* [stop] Stopping services.' 
        docker-compose down
    ;;
    summarize)
        echo "stop | | STOP flap services."
    ;;
    help|*)
        echo "
$(manager stop summarize)
Commands:
    '' | | STOP." | column -t -s "|"
    ;;
esac
