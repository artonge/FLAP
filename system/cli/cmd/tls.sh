#!/bin/bash

set -eu

CMD=${1:-}

# Make sure the domains folder exists
mkdir -p $FLAP_DATA/system/data/domains

case $CMD in
    generate)
        # Exit during CI or on local DEV.
        if [ "${CI:-false}" == "true" ] || [ "${DEV:-false}" == "true" ]
        then
            exit
        fi

        echo '* [tls] Generating certificates for domain names'

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
            $FLAP_DIR/system/cli/lib/tls/certificates/generate_certs.sh $domains
        } || { # Catch error
            echo "Failed to generate certificates."
            exit 1
        }
        ;;
    generate_localhost)
        echo '* [tls] Generating certificates for flap.localhost'

        # Create default flap.localhost domain if it is missing
        mkdir -p $FLAP_DATA/system/data/domains/flap.localhost
        echo "OK" > $FLAP_DATA/system/data/domains/flap.localhost/status.txt
        echo "local" > $FLAP_DATA/system/data/domains/flap.localhost/provider.txt
        touch $FLAP_DATA/system/data/domains/flap.localhost/authentication.txt
        touch $FLAP_DATA/system/data/domains/flap.localhost/logs.txt

        # Generate certificates for flap.localhost if they do not exists yet.
        if [ ! -f /etc/letsencrypt/live/flap/fullchain.pem ]
        then
            mkdir -p /etc/letsencrypt/live/flap
            openssl req \
                -x509 \
                -out /etc/letsencrypt/live/flap/fullchain.pem \
                -keyout /etc/letsencrypt/live/flap/privkey.pem \
                -newkey rsa:2048 -nodes -sha256 \
                -subj "/CN=flap.localhost" -extensions EXT \
                -config <(printf "[dn]\nCN=flap.localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$1\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
            cp /etc/letsencrypt/live/flap/fullchain.pem /etc/letsencrypt/live/flap/chain.pem
        fi

        echo "flap.localhost" > $FLAP_DATA/system/data/primary_domain.txt

        manager restart

        manager hooks post_domain_update

        manager restart
        ;;
    handle_request)
        echo '* [tls] Handling domain requests'
        manager tls handle_request_primary_update
        manager tls handle_request_domain_deletion
        manager tls handle_request_domain_creation
        ;;
    handle_request_primary_update)
        # Exit if their is no request
        if [ ! -f $FLAP_DATA/system/data/domain_update_primary.txt ]
        then
            exit 0
        fi

        # Exit if the request is HANDLED
        status=$(cat $FLAP_DATA/system/data/domain_update_primary.txt)
        if [ "$status" == "HANDLED" ]
        then
            exit 0
        fi

        echo '* [tls] Handling domain update request'
        # Handle primary domain update
        {
            echo "HANDLED" > $FLAP_DATA/system/data/domain_update_primary.txt &&
            manager hooks post_domain_update &&
            manager restart &&
            rm $FLAP_DATA/system/data/domain_update_primary.txt
        } || { # Catch error
            echo "" > $FLAP_DATA/system/data/domain_update_primary.txt
            exit 1
        }
        ;;
    handle_request_domain_deletion)
        # Exit if their is no request
        if [ ! -f $FLAP_DATA/system/data/domain_update_delete.txt ]
        then
            exit 0
        fi

        # Exit if the request is HANDLED
        status=$(cat $FLAP_DATA/system/data/domain_update_delete.txt)
        if [ "$status" == "HANDLED" ]
        then
            exit 0
        fi

        echo '* [tls] Handling domain delete request'
        # Handle domain deletion request
        {
            echo "HANDLED" > $FLAP_DATA/system/data/domain_update_delete.txt &&
            manager hooks post_domain_update &&
            manager restart &&
            rm $FLAP_DATA/system/data/domain_update_delete.txt
        } || { # Catch error
            echo "" > $FLAP_DATA/system/data/domain_update_delete.txt
            exit 1
        }

        ;;
    handle_request_domain_creation)
        # Handle new domains
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

        echo '* [tls] Handling domain create request'

        # Give time to the server to pick up the status change.
        sleep 2

        {
            manager stop &&
            manager tls generate &&
            echo "OK" > $FLAP_DATA/system/data/domains/$DOMAIN/status.txt &&
            manager start &&
            manager hooks post_domain_update &&
            manager restart
        } || { # Catch error
            echo "Failed to handle domain request."
            echo "ERROR" > $FLAP_DATA/system/data/domains/$DOMAIN/status.txt
            manager start
            exit 1
        }

        # If primary domain is emtpy, set the handled domain as primary.
        if [ "$(manager tls primary)" == "" ]
        then
            echo "Set $DOMAIN as primary."
            echo $DOMAIN > $FLAP_DATA/system/data/primary_domain.txt
        fi
        ;;
    update_dns_records)
        # Execute update script for each OK domain.
        for domain in $(ls $FLAP_DATA/system/data/domains)
        do
            status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)
            provider=$(cat $FLAP_DATA/system/data/domains/$domain/provider.txt)

            if [ "$status" == "OK" ]
            then
                {
                    $FLAP_DIR/system/cli/lib/tls/update/${provider}.sh $domain
                } || { # Catch error
                    echo "Failed to update $domain's DNS records."
                }
            fi
        done
        ;;
    list)
        $FLAP_DIR/system/cli/lib/tls/list_domains.sh
        ;;
    list_all)
        for domain in $DOMAIN_NAMES
        do
            status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)
            provider=$(cat $FLAP_DATA/system/data/domains/$domain/provider.txt | cut -d ' ' -f1)

            echo "$domain - $status - $provider"
            echo "files.$domain - $status - $provider - SUB"
            echo "sogo.$domain - $status - $provider - SUB"
            echo "auth.$domain - $status - $provider - SUB"
        done
        ;;
    primary)
        echo $PRIMARY_DOMAIN_NAME
        ;;
    summarize)
        echo "tls | [generate, handle_request, list, list_all, primary, generate_localhost, help] | Manage TLS certificates for Nginx."
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
    generate_localhost | | Create flap.localhost domain and generate certificates if none exists." | column -t -s "|"
        ;;
esac