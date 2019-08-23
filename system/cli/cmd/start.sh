#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        # Run post setup scripts for each services.
        if [ ! -d $FLAP_DATA/system ]
        then
            echo "SETTING UP"
            manager setup raid
            manager setup network
            manager setup cron
        fi

        echo "STARTING FLAP"

        # Go to FLAP_DIR for docker-compose.
        cd $FLAP_DIR

        # Generate config
        manager config generate

        # Start all services.
        docker-compose up --detach

        if [ ! -f $FLAP_DATA/system/data/installation_done.txt ]
        then
            # Run post setup scripts for each services.
            manager hooks post_install

            # Mark installation as done.
            touch $FLAP_DATA/system/data/installation_done.txt
        fi
    ;;
    summarize)
        echo "start | | Start flap services."
    ;;
    help|*)
        echo "
$(manager start summarize)
Commands:
    '' | | Start." | column -t -s "|"
    ;;
esac
