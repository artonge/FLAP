#!/bin/bash

set -eu

CMD=${1:-}
DIR=$(dirname "$(readlink -f "$0")")

case $CMD in
    summarize)
        echo "update | ['', <service_name>, help] | Handle update logique for FLAP."
        ;;
    help)
        echo "
update | Handle update logique for FLAP.
Commands:
    '' | | Update FLAP.
    <service_name> | | Run migration scripts for the service." | column -t -s "|"
        ;;
    "")
        echo "FETCHING REPO"
        # Prevent crontabs from running
        crontab -r || true

        # Go to FLAP_DIR for git cmds
        cd $FLAP_DIR
        git pull
        git submodule update

        # Fetch new docker images
        docker-compose pull

        echo "STOPING CONTAINERS"
        manager stop

        echo "RUNNING SYSTEM MIGRATIONS"
        # We need to update the system in first because the other services migrations
        # might need the results of the system migration.
        manager update system

        echo "RUNNING SERVICES MIGRATIONS"
        for service in $(ls --directory $FLAP_DIR/*/)
        do
            manager update $(basename $service)
        done

        echo "UPDATE CRON"
        manager setup cron

        echo "RESTARTING CONTAINERS"
        manager start

        echo "RUNNING POST-UPDATE HOOKS"
        # Run post_update hooks for each services
        manager hooks post_update

        # Clean docker objects
        docker system prune --all --force
        ;;
    *)
        SERVICE=$CMD

        # Get the base migration for the service.
        # The current migration is the last migration that was run.
        CURRENT_MIGRATION=$(cat $FLAP_DATA/$SERVICE/current_migration.txt)

        # Run migration scripts as long as there is some to run.
        while [ -f $FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh ]
        do
            echo "Migrating $SERVICE from $CURRENT_MIGRATION to $((CURRENT_MIGRATION+1))"
            $FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh
            CURRENT_MIGRATION=$((CURRENT_MIGRATION+1))
            echo $CURRENT_MIGRATION > $FLAP_DATA/$SERVICE/current_migration.txt
        done
        ;;
esac
