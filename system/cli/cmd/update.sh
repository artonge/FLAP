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
    update | [branch_name] | Update FLAP to the most recent version. Specify <branch_name> if you want to update to a given branch.
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
        # Go to FLAP_DIR for git cmds.
        cd $FLAP_DIR

        git fetch --tags --prune

        CURRENT_TAG=$(git describe --tags --abbrev=0)
        NEXT_TAG=$(git tag --sort version:refname | grep -A 1 $CURRENT_TAG | grep -v $CURRENT_TAG | cat)
        ARG_TAG=${1:-}
        TARGET_TAG=${ARG_TAG:-$NEXT_TAG}

        # Abort update if there is no TARGET_TAG.
        if [ "${TARGET_TAG:-0.0.0}" == '0.0.0' ]
        then
            echo '* [update] Nothing to update, exiting.'
            exit 0
        fi

        # Don't update if an update is already in progress.
        if [ -f /tmp/updating_flap.lock ]
        then
            echo '* [update] Update already in progress, exiting.'
            exit 0
        fi
        touch /tmp/updating_flap.lock

        {
            echo "* [update] Updating code to $TARGET_TAG." &&
            git checkout $TARGET_TAG &&
            git submodule update --init &&

            echo '* [update] Updating docker images.' &&
            # docker-compose needs a generated config. In case a new module is added during update, its config will be missing, so we generate it here.
            manager config generate_templates &&
            docker-compose --no-ansi pull
        } || {
            # When either the git update or the docker pull fails, it is safer to go back to the previous tag.
            # This will prevent from:
            # - starting without the docker images,
            # - running migrations on an unknown state.
            echo '* [update] ERROR - Fail to update, going back to previous commit.'
            git checkout $CURRENT_TAG
            git submodule update --init
            rm /tmp/updating_flap.lock
            exit 1
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

        {
            manager hooks clean &&

            echo '* [update] Starting containers.' &&
            manager start &&

            echo '* [update] Running some hooks.' &&
            manager hooks post_update &&
            manager hooks post_domain_update &&
            manager restart &&

            echo '* [update] Cleanning docker objects.' &&
            docker system prune --all --force
        } || {
            echo '* [update] ERROR - Fail to restart containers.'
            EXIT_CODE=1
        }

        manager setup cron

        rm /tmp/updating_flap.lock
        ;;
esac

exit $EXIT_CODE
