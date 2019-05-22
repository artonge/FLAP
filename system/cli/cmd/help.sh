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

        for cmd in $(ls ./cmd)
        do
            help_string+="  $(./cmd/${cmd} summarize)"$'\n'
        done
        echo "$help_string" | column --table --separator "|"
        ;;
esac
