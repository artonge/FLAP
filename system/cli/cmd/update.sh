#!/bin/bash

set -eu

# This file handles the update logic of a FLAP box.
# WARNING: If you change this file, the following update will not use the updated version. So make sure you don't break self calls.

CMD=${1:-}

EXIT_CODE=0

case $CMD in
    summarize)
        echo "update | [<branch_name>, migrate [service_name], help] | Handle update logique for FLAP."
        ;;
    help)
        echo "
$(manager update summarize)
Commands:
    update | [branch_name] | Update FLAP to to ost recent version. Specify <branch_name> if you want to update to a given branch.
    migrate | [service_name] | Run migrations for all or only the specified service." | column -t -s "|"
        ;;
    migrate)
        SERVICE=${2:-all}

        if [ "$SERVICE" == "all" ]
        then
            echo '* [update] Running migrations for all services.'
            for service in $(ls --directory $FLAP_DIR/*/)
            do
                {
                    manager update migrate $(basename $service)
                } || {
                    echo "* [update] ERROR - Fail to run migrations for $service."
                    EXIT_CODE=1
                }
            done
        else
            # Get the base migration for the service.
            # The current migration is the last migration that was run.
            CURRENT_MIGRATION=$(cat $FLAP_DATA/$SERVICE/current_migration.txt)

            # Run migration scripts as long as there is some to run.
            while [ -f $FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh ]
            do
                echo "* [update] Migrating $SERVICE from $CURRENT_MIGRATION to $((CURRENT_MIGRATION+1))"
                $FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh
                CURRENT_MIGRATION=$((CURRENT_MIGRATION+1))
                echo $CURRENT_MIGRATION > $FLAP_DATA/$SERVICE/current_migration.txt
            done
        fi
        ;;
    ""|*)
        # Don't update if one is already in progress.
        if [ -f $FLAP_DATA/system/data/updating.lock ]
        then
            exit 0
        fi

        touch $FLAP_DATA/system/data/updating.lock

        # Optionnaly use the second argument as the targeted branch. Default to the current branch.
        BRANCH=${1:-$(git rev-parse --abbrev-ref HEAD)}

        # Go to FLAP_DIR for git cmds.
        cd $FLAP_DIR

        COMMIT=$(git rev-parse HEAD)

        {
            echo "* [update] Updating code to branch $BRANCH."
            git checkout $BRANCH &&
            git pull origin $BRANCH &&
            git submodule update --init &&

            echo '* [update] Updating docker images.' &&
            # docker-compose needs a generated config. In case a new module is added during update, its config will be missing, so we generate it here.
            manager config generate_templates &&
            docker-compose --no-ansi pull
        } || {
            # When either the git update or the docker pull fails, it is safer to go back to the previous commit.
            # This will prevent from:
            # - starting without the docker images,
            # - running migrations on an unknown state.
            echo '* [update] ERROR - Fail to update, going back to previous commit.'
            git reset --hard $COMMIT
            git submodule update --init
            EXIT_CODE=1
        }

        echo '* [update] Stoping containers.'
        manager stop || true # "|| true" to prevent exiting the script on error.

        {
            # We need to update the system first because the other services migrations
            # might need the results of the system migration.
            manager update migrate system &&
            manager update migrate
        } || {
            echo '* [update] ERROR - Fail to run migrations.'
            EXIT_CODE=1
        }

        # Clean docker volumes to prevent persisting part of containers that should not be persisted.
        docker volume prune -f

        {
            echo '* [update] Restarting containers.'
            manager start &&

            echo '* [update] Running post-update hooks.'
            manager hooks post_update &&
            manager hooks post_domain_update &&
            manager restart &&

            echo '* [update] Cleanning docker objects.'
            docker system prune --all --force
        } || {
            echo '* [update] ERROR - Fail to restart containers.'
            EXIT_CODE=1
        }

        rm $FLAP_DATA/system/data/updating.lock
        ;;
esac

exit $EXIT_CODE
