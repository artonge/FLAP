#!/bin/bash

set -eu

CMD=${1:-}
DIR=$(dirname "$(readlink -f "$0")")

case $CMD in
    network)
        # Prevent some operations during CI.
        if [ ! ${CI:-false} ]
        then
            # Set local domain name to flap.local
            hostname flap
            # Create port mappings
            manager ports open 80
            manager ports open 443
        fi
    ;;
    raid)
        mkdir -p /flap

        # Prevent some operations during CI.
        if [ ! ${CI:-false} ]
        then
            manager disks setup
        fi

        # Create data directory for each services
        # And set current_migration.txt
        for service in $(ls -d $FLAP_DIR/*/)
        do
            mkdir -p $FLAP_DATA/$(basename $service)
            cat $FLAP_DIR/$(basename $service)/scripts/migrations/base_migration.txt > $FLAP_DATA/$(basename $service)/current_migration.txt
        done

        # Create log folder
        mkdir -p /var/log/flap
    ;;
    cron)
        cron_string="############## ENV ##############"$'\n'
        cron_string+="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"$'\n\n'

        # Build cron_string from services cron files
        for service in $(ls -d $FLAP_DIR/*/)
        do
            if [ -f $service/$(basename $service).cron ]
            then
                cron_string+="############## $(basename $service) ##############"$'\n'
                cron_string+="$(cat $service/$(basename $service).cron)"$'\n\n'
            fi
        done

        # Set the built string as the cron file
        echo "$cron_string" | crontab -
    ;;
    summarize)
        echo "setup | [cron, help] | Setup FLAP components."
        ;;
    help|*)
        echo "
setup | Setup FLAP components.
Commands:
    cron | | Setup the cron from service's cron files.
    network | | Setup the network (ports mapping and mDNS).
    raid | | Setup the RAID and directories used by FLAP." | column -t -s "|"
        ;;
esac
