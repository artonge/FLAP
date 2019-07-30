#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        manager stop
        manager start
    ;;
    summarize)
        echo "restart | | Restart flap services."
    ;;
    help|*)
        echo "
$(manager restart summarize)
Commands:
    '' | | Restart flap services." | column -t -s "|"
    ;;
esac