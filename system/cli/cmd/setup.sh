#!/bin/bash

set -e

CMD=$1
DIR=$(dirname "$(readlink -f "$0")")

case $CMD in
    cron)
        cron_string=""

        # Build cron_string from services cron files
        for service in $(ls $FLAP_DIR)
        do
            if [ -f $FLAP_DIR/$service/$service.cron ]
            then
                help_string+="############## $service ##############"$'\n'
                help_string+="$(cat $FLAP_DIR/$service/$service.cron)"$'\n\n'
            fi
        done

        # Set main.cron as the cron file
        echo "$help_string" | crontab -
    ;;
    summarize)
        echo "setup | [cron, help] | Setup FLAP composents."
        ;;
    help|*)
        echo "
setup | Setup FLAP composents.
Commands:
    cron | | Setup the cron from service's cron files." | column --table --separator "|"
        ;;
esac
