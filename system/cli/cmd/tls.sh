#!/bin/bash

set -e

CMD=$1

case $CMD in
    generate)
        DOMAIN_INFO=$(manager config show | grep DOMAIN_INFO | cut -d '=' -f2)

        STATUS=$(echo $DOMAIN_INFO | grep -E ' (HANDLED)|(OK)|(ERROR)$' | cat)

        # If the domain name has allready a status exit now, else continue and set the status to HANDLED.
        if [ "$STATUS" != "" ]
        then
            echo $DOMAIN_INFO
            exit 0
        fi

        echo "$DOMAIN_INFO HANDLED" > $FLAP_DATA/domainInfo.txt
        cd $FLAP_DIR

        {
            # Generate TLS certificates
            docker-compose down &&
            $FLAP_DIR/system/cli/lib/certificates/generate_certs.sh $DOMAIN_INFO 2>&1 &&
            echo "$DOMAIN_INFO OK" > $FLAP_DATA/domainInfo.txt &&
            manager config generate &&
            docker-compose up -d
        } || { # Catch error
            echo "Failed to generate certificates."
            echo "$DOMAIN_INFO ERROR" > $FLAP_DATA/domainInfo.txt
            docker-compose up -d
            exit 1
        }

        echo "Certificates generated."
        ;;
    show)
        ls -1 /etc/ssl/nginx | grep ".crt"
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