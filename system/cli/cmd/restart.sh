#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    "")
        echo "* [restart] Restarting services."
        flapctl stop
        flapctl start
    ;;
    summarize)
        echo "restart | | Restart flap services."
    ;;
    help|*)
        echo "
$(flapctl restart summarize)
Commands:
    '' | | Restart flap services." | column -t -s "|"
    ;;
esac
