#!/bin/bash

set -e

CMD=$1
DIR=$(dirname "$(readlink -f "$0")")

case $CMD in
    system)
        $DIR/../lib/update/update_system.sh
        ;;
    flap)
        $DIR/../lib/update/update_flap.sh
        ;;
    summarize)
        echo "update | [system, flap, help] | Handle update logique for the system and FLAP."
        ;;
    help|*)
        echo "
update | Handle update logique for the system and flap.
Commands:
    system | | Update the system.
    update | | Update FLAP." | column -t -s "|"
        ;;
esac
