#!/bin/bash

set -ex

CMD=$1

case $CMD in
    "")
        # Get the current config
        CONFIG=$(manager config show)
        # Get the previous config
        if [ ! -f /var/lib/flap/previous_config.txt ]
        then
            touch /var/lib/flap/previous_config.txt
        fi
        PREVIOUS_CONFIG=$(cat /var/lib/flap/previous_config.txt)

        # Get current domain info
        DOMAIN_INFO=$(echo "$CONFIG" | grep DOMAIN_INFO | cat)
        # Get previous domain info
        PREVIOUS_DOMAIN_INFO=$(echo "$PREVIOUS_CONFIG" | grep DOMAIN_INFO | cat)

        # If the domain info has change, we need to:
        # - generate TLS certificates
        # - update the services configuration
        # - restart all services
        if [ "$DOMAIN_INFO" != "$PREVIOUS_DOMAIN_INFO" ]
        then
            manager tls generate
            manager config generate
            docker-compose restart nginx
        fi

        # Save the current config
        echo "$CONFIG" > /var/lib/flap/previous_config.txt
        ;;
    summarize)
        echo "applychanges | [generate, show, help] | Apply changes to the configuration variables."
        ;;
    help|*)
        echo "applychanges | | Apply changes to the configuration variables." | column --table --separator "|"
        ;;
esac
