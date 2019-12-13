#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        # Go to FLAP_DIR for docker-compose.
        cd $FLAP_DIR

        # Generate configuration so docker-compose does not complains because of a missing config file.
        flapctl config generate_templates

        # Stop all services. If an error occures, the docker daemon will be restarted before retrying.
        echo '* [stop] Stopping services.' 
        docker-compose --no-ansi down --remove-orphans || systemctl restart docker || docker-compose --no-ansi down --remove-orphans
    ;;
    summarize)
        echo "stop | | STOP flap services."
    ;;
    help|*)
        echo "
$(flapctl stop summarize)
Commands:
    '' | | STOP." | column -t -s "|"
    ;;
esac
