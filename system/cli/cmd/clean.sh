#!/bin/bash

set -euo pipefail

CMD=${1:-}

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

if [ "${2:-}" == "-y" ]
then
    FORCE_YES=1
else
    FORCE_YES=0
fi

case $CMD in
    services)
        if [ "$FORCE_YES" == 0 ]
        then
            echo "* [clean] This will remove all the users data. Continue ? [Y/N]:"
            read -r answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Running clean hook.'

        flapctl hooks clean
        ;;
    config)
        if [ "$FORCE_YES" == 0 ]
        then
            echo "* [clean] This will remove all the configuration. Continue ? [Y/N]:"
            read -r answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning generated configuration.'

        # Remove crontab
        crontab -r || true

        # Remove files listed in gitignore
        cd "$FLAP_DIR"
        git clean "${args[@]}" -Xd --force
        ;;
    data)
        if [ "$FORCE_YES" == 0 ]
        then
            echo "* [clean] This will remove all the users data. Continue ? [Y/N]:"
            read -r answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning users data.'

        # Remove FLAP data files
        rm -rf "${FLAP_DATA:?}"/*
        docker volume prune -f
        ;;
    docker)
        if [ "$FORCE_YES" == 0 ]
        then
            echo "* [clean] This will remove all the docker objects. Continue ? [Y/N]:"
            read -r answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        if [ "${FLAG_NO_CLEAN_DOCKER:-}" == "true" ]
        then
            echo "* [clean:FEATURE_FLAG] Skip docker pruning."
            exit 0
        fi

        echo '* [clean] Cleaning docker objects.'

        # Remove docker objects
        docker container prune --force
        docker network   prune --force
        docker image     prune --force --all
        ;;
    ""|"-y")
        if [ "${1:-}" != "-y" ]
        then
            echo "* [clean] This will remove ALL the FLAP data. Continue ? [Y/N]:"
            read -r answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning FLAP.'
        flapctl clean services -y
        flapctl clean config -y
        flapctl clean data -y
        flapctl clean docker -y
        ;;
    summarize)
        echo "clean | [services, config, data, docker] | Clean data on the FLAP box. -y to bypass the validation."
        ;;
    help|*)
        echo "
$(flapctl clean summarize)
Commands:
    services | [-y] | Run clean hooks.
    config | [-y] | Remove the generated configuration.
    data | [-y] | Remove the users data.
    docker | [-y] | Remove the docker objects.
    '' | | Clean data on the FLAP box." | column -t -s "|"
        ;;
esac
