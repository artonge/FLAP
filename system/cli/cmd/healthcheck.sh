#!/bin/bash

set -e

CMD=$1

case $CMD in
    "")
        for service in $(ls $FLAP_DIR)
        do
            if [ -f $FLAP_DIR/$service/scripts/healthcheck.sh ]
            then
                $FLAP_DIR/$service/scripts/healthcheck.sh
            fi
        done
        ;;
    summarize)
        echo "healthcheck | | Run services healthcheck."
        ;;
    help|*)
        echo "
healthcheck | Run services healthcheck." | column -t -s "|"
        ;;
esac
