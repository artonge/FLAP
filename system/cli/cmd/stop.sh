#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    summarize)
        echo "stop | | STOP flap services."
    ;;
    help|*)
        echo "
$(manager stop summarize)
Commands:
    '' | | STOP." | column -t -s "|"
    ;;
    "")
        # Go to FLAP_DIR for docker-compose.
        cd $FLAP_DIR

        # Start all services.
        docker-compose down
    ;;
esac
