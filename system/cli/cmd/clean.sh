#!/bin/bash

set -eu

CMD=${1:-}

if [ "${2:-}" == "-y" ]
then
    FORCE_YES=1
else
    FORCE_YES=0
fi

case $CMD in
    config)
        if [ $FORCE_YES == 0 ]
        then
            read -p "This will remove all the configuration. Continue ? [Y/N]" answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning generated configuration.'

        # Remove crontab
        crontab -r || true

        # Remove files listed in gitignore
        cd $FLAP_DIR
        git clean -Xdf
        git submodule foreach "git clean -Xdf"
        ;;
    data)
        if [ $FORCE_YES == 0 ]
        then
            read -p "This will remove all the users data. Continue ? [Y/N]" answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning users data.'

        # Remove FLAP data files
        rm -rf $FLAP_DATA/*
        ;;
    docker)
        if [ $FORCE_YES == 0 ]
        then
            read -p "This will remove all the docker objects. Continue ? [Y/N]" answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning docker objects.'

        # Remove docker objects
        docker container prune -f
        docker volume prune -f
        docker network prune -f
        docker image prune -f
        ;;
    ""|*)
        if [ "${1:-}" != "-y" ]
        then
            read -p "This will remove ALL the FLAP data. Continue ? [Y/N]" answer

            if [ "$answer" == "${answer#[Yy]}" ]
            then
                exit 0
            fi
        fi

        echo '* [clean] Cleaning FLAP.'
        manager clean config -y
        manager clean data -y
        manager clean docker -y
        ;;
    summarize)
        echo "clean | [config, data, docker] | Clean data on the FLAP box. -y to bypass the validation."
        ;;
    help|*)
        printf "
$(manager clean summarize)
Commands:
    config | [-y] | Remove the generated configuration.
    data | [-y] | Remove the users data.
    docker | [-y] | Remove the docker objects.
    '' | | Clean data on the FLAP box." | column -t -s "|"
        ;;
esac
