#!/bin/bash

set -eu

CMD=${1:-}

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
                    echo "\* [update] ERROR - Fail to run migrations for $service."
                }
            done
        else
            echo "* [update] Running migrations for $SERVICE."

            # Make config available in migrations.
            export $(manager config show)

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
        fi
        ;;
    ""|*)
        # Optionnaly use the second argument as the targeted branch. Default to master.
        BRANCH=${2:-master}

        # Prevent crontabs from running.
        crontab -r || true # "|| true" to prevent exiting the script on error.

        # Go to FLAP_DIR for git cmds.
        cd $FLAP_DIR

        COMMIT=$(git rev-parse HEAD)

        {
            echo '* [update] Updating code.'
            git pull $BRANCH &&
            git submodule update --init &&

            echo '* [update] Updating docker images.' &&
            # docker-compose needs a generated config. In case a new module is added during update, its config will be missing, so we generate it here.
            manager config generate_templates &&
            docker-compose pull
        } || {
            # When either the git update or the docker pull fails, it is safer to go back to the previous commit.
            # This will prevent from:
            # - starting without the docker images,
            # - running migrations on an unknown state.
            echo '* [update] ERROR - Fail to update, going back to previous commit.'
            git reset --hard $COMMIT
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
        }

        # Clean docker volumes to prevent persisting part of containers that should not be persisted.
        docker volume prune -f

        {
            echo '* [update] Restarting containers.'
            manager start &&

            echo '* [update] Running post-update hooks.'
            manager hooks post_update &&

            echo '* [update] Cleanning docker objects.'
            docker system prune --all --force
        } || {
            echo '* [update] ERROR - Fail to restart containers.'
        }

        echo '* [update] Setting up cron jobs.'
        manager setup cron
        ;;
esac
