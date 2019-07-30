#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        read -p "The clean.sh script will remove all off the user data. Continue ? [Y/N]" answer

        if [ "$answer" == "${answer#[Yy]}" ]
        then
            exit 0
        fi

        echo "Cleaning..."

        # Remove crontab
        crontab -r

        # Remove files listed in gitignore
        git clean -Xdf
        git submodule foreach "git clean -Xdf"

        # Remove FLAP data files
        rm -rf /flap/*

        # Remove docker objects
        docker container prune -f && docker volume prune -f && docker network prune -f && docker image prune -f
        ;;
    summarize)
        echo "clean | | Clean data on the FLAP box."
        ;;
    help|*)
        printf "
$(manager clean summarize)
Commands:
    '' | | Setup RAID 1 array." | column -t -s "|"
        ;;
esac
