#!/bin/bash

set -e

CMD=$1

# Go to FLAP_DIR for docker-compose
cd $FLAP_DIR

case $CMD in
    "")
        docker-compose down
        rsync -a /flap /flap_backup
        docker-compose up -d
        ;;
    restore)
        docker-compose down
        rsync -a /flap_backup /flap
        docker-compose up -d
        ;;
    summarize)
        echo "backup | ['', restore, help] | Make and restore backup."
        ;;
    help|*)
        printf "
backup | Make and restore backup.
Commands:
    "" | | Setup disks if necessary.
    restore | | Format a disk to format that FLAP likes." | column -t -s "|"
        ;;
esac
