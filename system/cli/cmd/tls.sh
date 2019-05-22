#!/bin/bash

set -e

CMD=$1

case $CMD in
    generate)
        # Create default domainInfo.txt if it is missing
        if [ ! -f /var/lib/manager/domainInfo.txt ]
        then
            mkdir -p /var/lib/manager
            echo "flap.local local" > /var/lib/manager/domainInfo.txt
        fi

        DIR=$(dirname "$(readlink -f "$0")")
        DOMAIN_INFO=$(cat /var/lib/manager/domainInfo.txt)

        $DIR/../lib/certificates/generateCerts.sh $DOMAIN_INFO
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
    show | | Show the list of certificates." | column --table --separator "|"
        ;;
esac
