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
$(flapctl update summarize)
Commands:
    update | [branch_name] | Update FLAP to the most recent version. Specify <branch_name> if you want to update to a given branch.
    migrate | [service_name] | Run migrations for all or only the specified service." | column -t -s "|"
        ;;
    migrate)
        SERVICE=${2:-all}

        if [ "$SERVICE" == "all" ]
        then
            echo '* [update] Running migrations for all services.'
            for service in "$FLAP_DIR"/*/
            do
                if [ ! -d "$service" ]
                then
                    continue
                fi

                {
                    flapctl update migrate "$(basename "$service")"
                } || {
                    echo "* [update] ERROR - Fail to run migrations for $service."
                    EXIT_CODE=1
                }
            done
        else
            # Get the base migration for the service.
            # The current migration is the last migration that was run.
            CURRENT_MIGRATION=$(cat "$FLAP_DATA/$SERVICE/current_migration.txt")

            # Run migration scripts as long as there is some to run.
            while [ -f "$FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh" ]
            do
                echo "* [update] Migrating $SERVICE from $CURRENT_MIGRATION to $((CURRENT_MIGRATION+1))"
                "$FLAP_DIR/$SERVICE/scripts/migrations/$((CURRENT_MIGRATION+1)).sh"
                CURRENT_MIGRATION=$((CURRENT_MIGRATION+1))
                echo $CURRENT_MIGRATION > "$FLAP_DATA/$SERVICE/current_migration.txt"
            done
        fi
        ;;
    ""|*)
        # Go to FLAP_DIR for git cmds.
        cd "$FLAP_DIR"

        git fetch --tags --prune

        CURRENT_TAG=$(git describe --tags --abbrev=0)
        NEXT_TAG=$(git tag --sort version:refname | grep -A 1 "$CURRENT_TAG" | grep -v "$CURRENT_TAG" | cat)
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
            git checkout "$TARGET_TAG" &&

            # Pull changes if we are on a branch.
            if [ "$(git rev-parse --abbrev-ref HEAD)" != "HEAD" ]
            then
                git pull
            fi

            git submodule update --init &&

            # Update docker-compose.yml to pull new images.
            flapctl config generate_compose &&
            flapctl config generate_templates &&
            echo '* [update] Pulling new docker images.' &&
            docker-compose --no-ansi pull
        } || {
            # When either the git update or the docker pull fails, it is safer to go back to the previous tag.
            # This will prevent from:
            # - starting without the docker images,
            # - running migrations on an unknown state.
            echo '* [update] ERROR - Fail to update, going back to previous commit.'
            git submodule foreach "git add ."
            git submodule foreach "git reset --hard"
            git submodule foreach "git clean -Xdf"
            git add .
            git reset --hard
            git clean -Xdf
            git checkout "$CURRENT_TAG"
            git submodule update --init
            rm /tmp/updating_flap.lock
            exit 1
        }

        echo '* [update] Stoping containers.'
        flapctl stop || true # "|| true" to prevent exiting the script on error.

        # Setting up fs for new services.
        flapctl setup fs

        {
            # We need to update the system first because the other services migrations
            # might need the results of the system migration.
            flapctl update migrate system &&
            flapctl update migrate
        } || {
            echo '* [update] ERROR - Fail to run migrations.'
            EXIT_CODE=1
        }

        {
            flapctl hooks clean &&

            echo '* [update] Starting containers.' &&
            flapctl start &&

            flapctl hooks post_update &&

            echo '* [update] Cleanning docker objects.' &&
            flapctl clean docker -y
        } || {
            echo '* [update] ERROR - Fail to restart containers.'
            EXIT_CODE=1
        }

        flapctl setup cron

        rm /tmp/updating_flap.lock
        ;;
esac

exit $EXIT_CODE
