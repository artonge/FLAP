#!/bin/bash

set -eu

CMD=${1:-}

# Make sure the domains folder exists
mkdir -p $FLAP_DATA/system/data/domains

case $CMD in
    generate)
        # Filter domains that are either OK or HANDLED and not for "local" or "localhost"
        domains=""
        for domain in $(ls $FLAP_DATA/system/data/domains)
        do
            status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)
            provider=$(cat $FLAP_DATA/system/data/domains/$domain/provider.txt | cut -d ' ' -f1)

            if ( [ "$status" == "OK" ] || [ "$status" == "HANDLED" ] ) && [ "$provider" != "localhost" ] && [ "$provider" != "local" ]
            then
                domains+="$domain "
            fi
        done

        {
            # Generate TLS certificates
            $FLAP_DIR/system/cli/lib/certificates/generate_certs.sh $domains
        } || { # Catch error
            echo "Failed to generate certificates."
            exit 1
        }
        ;;
    generate_local)
        # Create default flap.localhost domain if it is missing
        if [ ! -f $FLAP_DATA/system/data/domains/flap.localhost ]
        then
            mkdir -p $FLAP_DATA/system/data/domains/flap.localhost
            echo "OK" > $FLAP_DATA/system/data/domains/flap.localhost/status.txt
            echo "local" > $FLAP_DATA/system/data/domains/flap.localhost/provider.txt
        fi

        mkdir -p /etc/ssl/nginx
        if [ ! -f /etc/ssl/nginx/privkey.key ]
        then
            # Generate certificates for flap.localhost
            # When there is no configurated domain names, this certificates can be used by nginx.
            openssl req -x509 -out /etc/ssl/nginx/fullchain.crt -keyout /etc/ssl/nginx/privkey.key \
                -newkey rsa:2048 -nodes -sha256 \
                -subj "/CN=flapen.localhost" -extensions EXT \
                -config <(printf "[dn]\nCN=flap.localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$1\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
            cp /etc/ssl/nginx/fullchain.crt /etc/ssl/nginx/chain.pem
        fi
        ;;
    handle_request)
        mkdir -p $FLAP_DATA/system/data/domains

        # Select a WAITING domain
        for domain in $(ls $FLAP_DATA/system/data/domains)
        do
            status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)

            if [ "$status" == "WAITING" ]
            then
                DOMAIN=$domain
                echo "HANDLED" > $FLAP_DATA/system/data/domains/$DOMAIN/status.txt
                break
            fi
        done

        # If there was no WAITING domain, exit
        if [ -z "${DOMAIN:-}" ]
        then
            exit 0
        fi

        # Give time to the server to pick up the status change.
        sleep 2

        {
            manager stop &&
            manager tls generate &> $FLAP_DATA/system/data/domains/$domain/logs.txt &&
            echo "OK" > $FLAP_DATA/system/data/domains/$DOMAIN/status.txt &&
            manager start &&
            manager hooks post_domain_update
        } || { # Catch error
            echo "Failed to handle domain request."
            echo "ERROR" > $FLAP_DATA/system/data/domains/$DOMAIN/status.txt
            manager start
            exit 1
        }

        # If primary domain is a local domain, set the handled domain as primary.
        primary_is_local=$(manager tls primary | grep -v local | cat)
        if [ "$primary_is_local" == "" ]
        then
            echo "Set $DOMAIN as primary."
            echo $DOMAIN > $FLAP_DATA/system/data/primary_domain.txt
        fi
        ;;
    list)
        for domain in $(ls $FLAP_DATA/system/data/domains)
        do
            status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)
            provider=$(cat $FLAP_DATA/system/data/domains/$domain/provider.txt | cut -d ' ' -f1)

            echo "$domain - $status - $provider"
        done
        ;;
    list_all)
        for domain in $(ls $FLAP_DATA/system/data/domains)
        do
            status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)
            provider=$(cat $FLAP_DATA/system/data/domains/$domain/provider.txt | cut -d ' ' -f1)

            echo "$domain - $status - $provider"
            echo "files.$domain - $status - $provider - SUB"
            echo "sogo.$domain - $status - $provider - SUB"
        done
        ;;
    primary)
        # If no primary is set, set the first one.
        if [ ! -f $FLAP_DATA/system/data/primary_domain.txt ] || [ "$(cat $FLAP_DATA/system/data/primary_domain.txt)" == "" ]
        then
            domains=($(manager tls list))
            echo ${domains[0]} > $FLAP_DATA/system/data/primary_domain.txt
        fi

        cat $FLAP_DATA/system/data/primary_domain.txt
        ;;
    summarize)
        echo "tls | [generate, handle_request, list, list_all, primary, generate_local, help] | Manage TLS certificates for Nginx."
        ;;
    help|*)
        echo "
tls | Manage TLS certificates for Nginx.
Commands:
    generate | | Generate certificates for the current domain name.
    handle_request | | Handle WAITING domain names.
    list | | Show the full list of domain names and their information.
    list_all | | Same as 'list' but with subdomains.
    primary | | Show the primary domain name.
    generate_local | | Create flap.localhost domain and generate certificates if none exists." | column -t -s "|"
        ;;
esac