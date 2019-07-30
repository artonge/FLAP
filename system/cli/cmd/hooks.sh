#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    post_install|post_update|post_domain_update|health_check)
        echo "Running $CMD hook:"
        for service in $(ls --directory $FLAP_DIR/*/)
        do
            if [ -f $service/scripts/hooks/$CMD.sh ]
            then
                echo "  - $(basename $service)"
                $service/scripts/hooks/$CMD.sh
            fi
        done
        ;;
    summarize)
        echo "hooks | [post_install, post_update, post_domain_update, health_check] | Run hooks."
        ;;
    help|*)
        echo "
hooks | Run hooks.
Commands:
    generate | <post_install, post_update, post_domain_update, health_check> | Run the provided hook." | column -t -s "|"
esac
