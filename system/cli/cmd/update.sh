#!/bin/bash

set -e

CMD=$1
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
        git pull
        git submodule update

        # Fetch new docker images
        cd $FLAP_DIR
        docker-compose pull

        echo "RUNNING SYSTEM MIGRATIONS"
        # We need to update the system in first because the other services migrations
        # might need the results of the system migration.
        manager update system

        echo "RUNNING SERVICES MIGRATIONS"
        for service in $(ls -d $FLAP_DIR/*/)
        do
            manager update $(basename $service)
        done

        echo "GENERATING CONFIGURATION"
        manager setup cron
        manager config generate

        echo "RESTARTING CONTAINERS"
        docker-compose down
        docker-compose up -d

        echo "RUNNING POST-UPDATE HOOKS"
        # Run post_update hooks for each services
        manager hooks post_update
        ;;
    *)
        SERVICE=$CMD

        # Get the base migration for the service.
        # The base migration is the migration that would be in place after a fresh install.
        CURRENT_MIGRATION=$(cat /flap/$SERVICE/scripts/migrations/base_migration.txt)
        # Get the current migration for the service.
        # The current migration is the last migration that was run if it is not a fresh install.
        if [ -f /flap/$SERVICE/current_migration.txt ]
        then
            CURRENT_MIGRATION=$(cat /flap/$SERVICE/current_migration.txt)
        fi

        # Run migration scripts as long as there is some to run.
        while [ -f $FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh ]
        do
            echo "Migrating $SERVICE from $CURRENT_MIGRATION to $((CURRENT_MIGRATION+1))"
            $FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh
            CURRENT_MIGRATION=$((CURRENT_MIGRATION+1))
            echo $CURRENT_MIGRATION > /flap/$SERVICE/current_migration.txt
        done
        ;;
esac
