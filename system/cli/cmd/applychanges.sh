#!/bin/bash

set -e

CMD=$1

case $CMD in
    "")
        # Get the current config
        CONFIG=$(manager config show)
        # Get the previous config, create it if it does not exists
        if [ ! -f $FLAP_DATA/previous_config.txt ]
        then
            touch $FLAP_DATA/previous_config.txt
        fi
        PREVIOUS_CONFIG=$(cat $FLAP_DATA/previous_config.txt)

        # Get current domain info
        DOMAIN_INFO=$(echo "$CONFIG" | grep DOMAIN_INFO | cat)
        # Get previous domain info
        PREVIOUS_DOMAIN_INFO=$(echo "$PREVIOUS_CONFIG" | grep DOMAIN_INFO | cat)

        # If the domain info has change, we need to:
        # - generate TLS certificates
        # - update the services configuration
        # - restart nginx
        if [ "$DOMAIN_INFO" != "$PREVIOUS_DOMAIN_INFO" ]
        then
            # Save the current config now, so we don't detect change a second time
            echo "$CONFIG" > $FLAP_DATA/previous_config.txt

            manager tls generate
            manager config generate
            docker-compose restart nginx
        fi
        ;;
    summarize)
        echo "applychanges | | Apply changes made to the configuration variables."
        ;;
    help|*)
        echo "applychanges | | Apply changes made to the configuration variables." | column -t -s "|"
        ;;
esac
