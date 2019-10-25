#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        # Run some setup operation if the installation is not done.
        if [ ! -f $FLAP_DATA/system/data/installation_done.txt ]
        then
            echo '* [start] Running setup operations.'
            manager setup raid
            manager setup network
            manager setup cron
        fi

        # Go to FLAP_DIR for docker-compose.
        cd $FLAP_DIR

        # Generate config
        manager config generate

        # Start all services.
        echo '* [start] Starting services.'
        docker-compose --no-ansi up --detach

        if [ ! -f $FLAP_DATA/system/data/installation_done.txt ]
        then
            # Run post setup scripts for each services.
            manager hooks post_install

            # Mark the installation as done.
            touch $FLAP_DATA/system/data/installation_done.txt
        fi

        # Generate certificates for flap.localhost on CI mode.
        if [[ ( "${DEV:-false}" == "false" || "${CI:-false}" != "false" ) && "$(manager tls primary)" == "" ]]
        then
            manager tls generate_localhost
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
