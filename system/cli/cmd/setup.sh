#!/bin/bash

set -e

CMD=$1
DIR=$(dirname "$(readlink -f "$0")")

case $CMD in
    cron)
        $DIR/../lib/setup/setup_cron.sh
        ;;
    summarize)
        echo "setup | [cron, help] | Setup FLAP composents."
        ;;
    help|*)
        echo "
setup | Setup FLAP composents.
Commands:
    cron | | Setup the cron from service's cron files." | column --table --separator "|"
        ;;
esac
