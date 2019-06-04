#!/bin/bash

set -e

CMD=$1
DIR=$(dirname "$(readlink -f "$0")")

case $CMD in
    cron)
        cron_string="############## ENV ##############"$'\n'
        cron_string+="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"$'\n'

        # Build cron_string from services cron files
        for service in $(ls $FLAP_DIR)
        do
            if [ -f $FLAP_DIR/$service/$service.cron ]
            then
                cron_string+="############## $service ##############"$'\n'
                cron_string+="$(cat $FLAP_DIR/$service/$service.cron)"$'\n\n'
            fi
        done

        # Set the built string as the cron file
        echo "$cron_string" | crontab -
    ;;
    summarize)
        echo "setup | [cron, help] | Setup FLAP composents."
        ;;
    help|*)
        echo "
setup | Setup FLAP composents.
Commands:
    cron | | Setup the cron from service's cron files." | column -t -s "|"
        ;;
esac
