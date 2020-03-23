#!/bin/bash

set -eu

CMD=${1:-}

# Make sure the domains folder exists
mkdir -p "$FLAP_DATA/system/data/domains"

case $CMD in
    generate)
		if [ "${FLAG_NO_TLS_GENERATION:-}" == "true" ]
		then
			echo '* [tls:FEATURE_FLAG] Skipping TLS generation.'
			exit
		fi

        echo '* [tls] Generating certificates for domain names.'

        # Filter domains that are either OK or HANDLED and not for "local" or "localhost"
        domains=()
        for domain in "$FLAP_DATA"/system/data/domains/*
        do
            [[ -e "$domain" ]] || break  # handle the case of no domain

            status=$(cat "$domain/status.txt")
            provider=$(cat "$domain/provider.txt")

            if { [ "$status" == "OK" ] || [ "$status" == "HANDLED" ]; } && [ "$provider" != "localhost" ] && [ "$provider" != "local" ]
            then
                domains+=("$(basename "$domain")")
            fi
        done

        {
            # Generate TLS certificates
            "$FLAP_DIR/system/cli/lib/tls/certificates/generate_certs.sh" "${domains[@]}"
        } || { # Catch error
            echo "Failed to generate certificates."
            exit 1
        }
        ;;
    generate_localhost)
        domain=${2:-flap.localhost}

		echo "* [tls] Generating certificates for $domain"

        # Create default flap.localhost domain if it is missing
        mkdir -p "$FLAP_DATA/system/data/domains/$domain"
        echo "OK" > "$FLAP_DATA/system/data/domains/$domain/status.txt"
        echo "local" > "$FLAP_DATA/system/data/domains/$domain/provider.txt"
        touch "$FLAP_DATA/system/data/domains/$domain/authentication.txt"
        touch "$FLAP_DATA/system/data/domains/$domain/logs.txt"

        # Generate certificates for flap.localhost if they do not exists yet.
		cert_path=/etc/letsencrypt/live/flap
        if [ ! -f $cert_path/fullchain.pem ]
        then
            mkdir -p $cert_path

			echo "[ req ]
prompt             = no
string_mask        = default
default_bits       = 2048
distinguished_name = req_distinguished_name
x509_extensions    = x509_ext
[ req_distinguished_name ]
organizationName = FLAP
commonName = FLAP localhost Root CA
[ x509_ext ]
basicConstraints=critical,CA:true,pathlen:0
keyUsage=critical,keyCertSign,cRLSign" > $cert_path/root_ca.conf

			echo "[ req ]
prompt             = no
string_mask        = default
default_bits       = 2048
distinguished_name = req_distinguished_name
x509_extensions    = x509_ext
[ req_distinguished_name ]
organizationName = FLAP
commonName = $domain
[ x509_ext ]
keyUsage=critical,digitalSignature,keyAgreement
subjectAltName = @alt_names
[alt_names]
DNS.1 = $domain
DNS.2 = files.$domain
DNS.3 = mail.$domain
DNS.4 = auth.$domain" > $cert_path/server_cert.conf

			openssl req \
				-nodes \
				-x509 \
				-new \
				-keyout $cert_path/root.key \
				-out $cert_path/root.cer \
				-config $cert_path/root_ca.conf
			openssl req \
				-nodes \
				-new \
				-keyout $cert_path/server.key \
				-out $cert_path/server.csr \
				-config $cert_path/server_cert.conf
			openssl x509 \
				-days 3650 \
				-req \
				-in $cert_path/server.csr \
				-CA $cert_path/root.cer \
				-CAkey $cert_path/root.key \
				-set_serial 123 \
				-out $cert_path/server.cer \
				-extfile $cert_path/server_cert.conf \
				-extensions x509_ext

			cp $cert_path/server.cer $cert_path/fullchain.pem
			cp $cert_path/server.key $cert_path/privkey.pem
			cp $cert_path/root.cer $cert_path/chain.pem
        fi

        echo "$domain" > "$FLAP_DATA/system/data/primary_domain.txt"

        flapctl restart

        flapctl hooks post_domain_update

        flapctl restart

		echo ""
		echo "You can install the following CA in your browser to ease development: $cert_path/root.cer"
        ;;
    handle_request)
        echo '* [tls] Handling domain requests'
        flapctl tls handle_request_primary_update
        flapctl tls handle_request_domain_deletion
        flapctl tls handle_request_domain_creation
        ;;
    handle_request_primary_update)
        # Exit if there is no request.
        if [ ! -f "$FLAP_DATA/system/data/domain_update_primary.txt" ]
        then
            exit 0
        fi

        # Exit if the request is HANDLED
        status=$(cat "$FLAP_DATA/system/data/domain_update_primary.txt")
        if [ "$status" == "HANDLED" ]
        then
            exit 0
        fi

        echo '* [tls] Handling domain update request'
        # Handle primary domain update
        {
            echo "HANDLED" > "$FLAP_DATA/system/data/domain_update_primary.txt" &&
            flapctl hooks post_domain_update &&
            flapctl restart &&
            rm "$FLAP_DATA/system/data/domain_update_primary.txt"
        } || { # Catch error
            echo "" > "$FLAP_DATA/system/data/domain_update_primary.txt"
            exit 1
        }
        ;;
    handle_request_domain_deletion)
        # Exit if their is no request
        if [ ! -f "$FLAP_DATA/system/data/domain_update_delete.txt" ]
        then
            exit 0
        fi

        # Exit if the request is HANDLED
        status=$(cat "$FLAP_DATA/system/data/domain_update_delete.txt")
        if [ "$status" == "HANDLED" ]
        then
            exit 0
        fi

        echo '* [tls] Handling domain delete request'
        # Handle domain deletion request
        {
            echo "HANDLED" > "$FLAP_DATA/system/data/domain_update_delete.txt" &&
            flapctl hooks post_domain_update &&
            flapctl restart &&
            rm "$FLAP_DATA/system/data/domain_update_delete.txt"
        } || { # Catch error
            echo "" > "$FLAP_DATA/system/data/domain_update_delete.txt"
            exit 1
        }

        ;;
    handle_request_domain_creation)
        # Handle new domains
        mkdir -p "$FLAP_DATA/system/data/domains"

        # Select a WAITING domain
        for domain in "$FLAP_DATA"/system/data/domains/*
        do
            [[ -e "$domain" ]] || break  # handle the case of no domain

            if [ "$(cat "$domain/status.txt")" == "WAITING" ]
            then
                DOMAIN=$(basename "$domain")
                echo "HANDLED" > "$domain/status.txt"
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
            flapctl tls register_domain "$DOMAIN" &&
            flapctl stop &&
            flapctl tls generate &&
            echo "OK" > "$FLAP_DATA/system/data/domains/$DOMAIN/status.txt" &&
            {
                # If primary domain is emtpy, set the handled domain as primary.
                if [ "$(flapctl tls primary)" == "" ]
                then
                    echo "* [tls] Set $DOMAIN as primary."
                    echo "$DOMAIN" > "$FLAP_DATA/system/data/primary_domain.txt"
                fi
            } &&
            flapctl start &&
            flapctl hooks post_domain_update &&
            flapctl restart
        } || { # Catch error
            echo "Failed to handle domain request."
            echo "ERROR" > "$FLAP_DATA/system/data/domains/$DOMAIN/status.txt"
            # Generate certificates if they were remove
            if [ ! -d /etc/letsencrypt/live/flap ]
            then
                flapctl tls generate
            fi
            flapctl start
            exit 1
        }
        ;;
    register_domain)
        # Execute update script for each OK domain or the provided ones.
        domain=${2:-}

        if [ "$domain" == ""  ]
        then
            exit 0
        fi

        provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")

        if [ ! -f "$FLAP_DIR/system/cli/lib/tls/register/${provider}.sh" ]
        then
            exit 0
        fi

        {
			"$FLAP_DIR/system/cli/lib/tls/register/${provider}.sh" "$domain" &&
			"$FLAP_DIR/system/cli/lib/tls/update/${provider}.sh" "$domain" &&
			test "$(flapctl ip dns "$DOMAIN")" == "$(flapctl ip external)"
        } || { # Catch error
            echo "Failed to register $domain."
        }
        ;;
    update_dns_records)
		if [ "${FLAG_LOCALHOST_TLS_INSTALL:-}" == "true" ] || [ "${FLAG_NO_DNS_RECORD_UPDATE:-}" == "true" ]
		then
			echo '* [tls:FEATURE_FLAG] Skipping DNS update.'
			exit
		fi

		# Get current external IP to check if it is necessary to update the DNS.
		EXTERNAL_IP=$(flapctl ip external)

        # Execute update script for each OK domain or the provided ones.
        read -r -a domains <<< "$DOMAIN_NAMES"

        if [ "$#" -gt "1" ]
        then
            domains=("$@")
            domains=("${domains[@]:1}")
        fi

        for domain in "${domains[@]}"
        do
			# Don't update DNS records if the ip is correct.
			HOST_IP=$(flapctl ip dns "$domain")
			if [ "$EXTERNAL_IP" == "$HOST_IP" ]
			then
				echo "* [tls] IP is ok for $domain, skipping."
				continue
			fi

            provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")

            {
                "$FLAP_DIR/system/cli/lib/tls/update/${provider}.sh" "$domain"
            } || { # Catch error
                echo "Failed to update $domain's DNS records."
            }
        done
        ;;
    list)
        "$FLAP_DIR/system/cli/lib/tls/list_domains.sh"
        ;;
    list_all)
        for domain in $DOMAIN_NAMES
        do
            status=$(cat "$FLAP_DATA/system/data/domains/$domain/status.txt")
            provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")

            echo "$domain - $status - $provider"
            for subdomain in $SUBDOMAINS
            do
                echo "$subdomain.$domain - $status - $provider - SUB"
            done
        done
        ;;
    primary)
        echo "$PRIMARY_DOMAIN_NAME"
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
