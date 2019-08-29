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
        # Prevent crontabs from running.
        crontab -r || true # "|| true" to prevent exiting the script on error.
    
        # Go to FLAP_DIR for git cmds.
        cd $FLAP_DIR

        COMMIT=$(git rev-parse HEAD)

        {
            echo '* Updating code.'
            git pull &&
            git submodule update &&

            echo '* Updating docker images.'
            docker-compose pull
        } || {
            # When either the git update or the docker pull fails, it is safer to go back to the previous commit.
            # This will prevent from:
            # - starting without the docker images,
            # - running migrations on unknown an state.
            echo '* ERROR - Fail to update, going back to previous commit.'
            git reset --hard $COMMIT
        }

        echo '* Stoping containers.'
        manager stop || true # "|| true" to prevent exiting the script on error.

        {
            # We need to update the system first because the other services migrations
            # might need the results of the system migration.
            echo '* Running system migrations.'
            manager update system &&

            echo '* Running other services migrations.'
            for service in $(ls --directory $FLAP_DIR/*/)
            do
                manager update $(basename $service)
            done
        } || {
            echo '* ERROR - Fail to run migrations.'
        }

        {
            echo '* Restarting containers.'
            manager start &&

            echo '* Running post-update hooks.'
            manager hooks post_update &&

            echo '* Cleanning docker objects.'
            docker system prune --all --force
        } || {
            echo '* ERROR - Fail to restart containers.'
        }

        echo '* Setting up cron jobs.'
        manager setup cron
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
