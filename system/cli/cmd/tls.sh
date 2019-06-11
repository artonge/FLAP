#!/bin/bash

set -e

CMD=$1
ARGS=($@)
ARGS=${ARGS[@]:1}

case $CMD in
    generate)
        # Go to the flap directory to stop and start containers
        cd $FLAP_DIR

        {
            # Generate TLS certificates
            $FLAP_DIR/system/cli/lib/certificates/generate_certs.sh $ARGS 2>&1
        } || { # Catch error
            echo "Failed to generate certificates."
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
    generate | <domain_name> <provider> <authentication> | Generate certificates for the current domain name.
    show | | Show the list of certificates." | column -t -s "|"
        ;;
esac