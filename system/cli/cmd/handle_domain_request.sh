#!/bin/bash

set -e

CMD=$1

case $CMD in
    "")
        mkdir -p $FLAP_DATA
        touch $FLAP_DATA/domainInfo.txt
        touch $FLAP_DATA/domainRequest.txt
        touch $FLAP_DATA/domainRequestStatus.txt

        # Only process when the request is WAITING
        REQUEST_STATUS=$(cat $FLAP_DATA/domainRequestStatus.txt)
        if [ "$REQUEST_STATUS" != "WAITING" ] && [ "$REQUEST_STATUS" != "" ]
        then
            exit 0
        fi

        # Set the request as HANDLING
        echo "HANDLING" > $FLAP_DATA/domainRequestStatus.txt

        # Allow the server to pick up the status change.
        sleep 2

        REQUEST=$(cat $FLAP_DATA/domainRequest.txt)

        cd $FLAP_DIR

        {
            docker-compose down &&
            manager tls generate $REQUEST &&
            echo $REQUEST > $FLAP_DATA/domainInfo.txt &&
            echo "OK" > $FLAP_DATA/domainRequestStatus.txt &&
            manager config generate &&
            docker-compose up -d &&
            manager hooks post_domain_update
        } || { # Catch error
            echo "Failed to handle domain request."
            echo "ERROR" > $FLAP_DATA/domainRequestStatus.txt
            docker-compose up -d
            exit 1
        }
        ;;
    summarize)
        echo "handle_domain_request | [help] | Handle domain requests if any."
        ;;
    help|*)
        echo "
handle_domain_request | Handle domain requests if any." | column -t -s "|"
        ;;
esac