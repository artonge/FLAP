#!/bin/bash

set -e

CMD=$1

case $CMD in
    summarize)
        echo "help | | Show help."
        ;;
    help|*)
        echo "Commands:"

        help_string=""

        for cmd in $(ls $FLAP_DIR/system/cli/cmd)
        do
            help_string+="  $($FLAP_DIR/system/cli/cmd/$cmd summarize)"$'\n'
        done
        echo "$help_string" | column --table --separator "|"
        ;;
esac
