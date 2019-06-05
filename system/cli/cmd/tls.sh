#!/bin/bash

set -e

CMD=$1

case $CMD in
    generate)
        mkdir -p $FLAP_DATA
        touch $FLAP_DATA/domainInfo.txt
        touch $FLAP_DATA/domainRequest.txt
        touch $FLAP_DATA/domainRequestStatus.txt

        # Only process when the request is WAITING
        REQUEST_STATUS=$(cat $FLAP_DATA/domainRequestStatus.txt)
        if [ "$REQUEST_STATUS" != "WAITING" ] || [ "$REQUEST_STATUS" != "" ]
        then
            exit 0
        fi

        # Set the request as HANDLING
        echo "HANDLING" > $FLAP_DATA/domainRequestStatus.txt

        # Allow the server to pick up the status change.
        sleep 2

        # Go to the flap directory to stop and start containers
        cd $FLAP_DIR
        {
            # Generate TLS certificates
            REQUEST=$(cat $FLAP_DATA/domainRequest.txt) &&
            docker-compose down &&
            $FLAP_DIR/system/cli/lib/certificates/generate_certs.sh $REQUEST 2>&1 &&
            echo $REQUEST > $FLAP_DATA/domainInfo.txt &&
            echo "OK" > $FLAP_DATA/domainRequestStatus.txt &&
            manager config generate &&
            docker-compose up -d
        } || { # Catch error
            echo "Failed to generate certificates."
            echo "ERROR" > $FLAP_DATA/domainRequestStatus.txt
            docker-compose up -d
            exit 1
        }
        ;;
    show)
        ls -1 /etc/letsencrypt/live
        ;;
    summarize)
        echo "tls | [show, generate, help] | Manage TLS certificates for Nginx."
        ;;
    help|*)
        echo "
tls | Manage TLS certificates for Nginx.
Commands:
    generate | | Generate certificates for the current domain name.
    show | | Show the list of certificates." | column -t -s "|"
        ;;
esac