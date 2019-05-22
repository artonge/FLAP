#!/bin/bash

set -e

CMD=$1

case $CMD in
    generate)
        # Create default domainInfo.txt if it is missing
        if [ ! -f /var/lib/flap/domainInfo.txt ]
        then
            mkdir -p /var/lib/flap
            echo "flap.local local" > /var/lib/flap/domainInfo.txt
        fi

        DOMAIN_INFO=$(cat /var/lib/flap/domainInfo.txt)

        {
            # Generate TLS certificates
            $FLAP_DIR/system/cli/lib/certificates/generate_certs.sh $DOMAIN_INFO
            echo "Certificates generated."

            # Add OK at the end of the domain info to mark it as handled
            if [ echo $DOMAIN_INFO | grep OK ]
            then
                echo "$DOMAIN_INFO OK" > /var/lib/flap/domainInfo.txt
            fi
        } || { # Catch error
            echo "Failed to generate certificates."
        }
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
