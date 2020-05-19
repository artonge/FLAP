#!/bin/bash

set -eu

CMD=${1:-}

# Make sure the domains folder exists
mkdir -p "$FLAP_DATA/system/data/domains"

case $CMD in
	add)
		domainname=$2

		echo "Create domain $domainname ? [Y/N]:"
		read -r answer

		if [ "$answer" == "${answer#[Yy]}" ]
		then
			exit 0
		fi

		# HACK: wget output does not contain a new line, so the log is weird.
		# We can not exec an 'echo ""' because when it fails the script return ealry.
		# We add a `| cat` to prevent exiting early on error.
		# Then we catch the error code with PIPESTATUS, exec `echo ""` and return the exit code.
		wget \
			--method POST \
			--header 'Host: flap.local' \
			--header 'Content-Type: application/json' \
			--body-data "{ \"name\": \"$domainname\", \"provider\": \"unknown\" }" \
			--quiet \
			--output-document=- \
			--content-on-error \
			http://localhost/api/domains | cat

		# Catch error code
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" != "0" ]
		then
			exit "$exit_code"
		fi

		flapctl domains handle_request

		echo ""
		echo "* [users] The domain '$domainname was added."
	;;
    handle_request)
        echo '* [tls] Handling domain requests'
        flapctl domains handle_request_primary_update
        flapctl domains handle_request_domain_deletion
        flapctl domains handle_request_domain_creation
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
            flapctl domains register_domain "$DOMAIN" &&
            flapctl stop &&
            flapctl tls generate &&
            echo "OK" > "$FLAP_DATA/system/data/domains/$DOMAIN/status.txt" &&
            {
                # If primary domain is emtpy, set the handled domain as primary.
                if [ "$(flapctl domains primary)" == "" ]
                then
                    echo "* [tls] Set $DOMAIN as primary."
                    echo "$DOMAIN" > "$FLAP_DATA/system/data/primary_domain.txt"
                fi
            } &&
            flapctl start &&
            flapctl hooks post_domain_update
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

		echo "* [tls] Registering domain name"

		"$FLAP_DIR/system/cli/lib/tls/register/${provider}.sh" "$domain"
		"$FLAP_DIR/system/cli/lib/tls/update/${provider}.sh" "$domain"

		elapse=0
		until [ "$(flapctl ip dns "$domain")" == "$(flapctl ip external)" ] > /dev/null
		do
			echo "Waiting for DNS propagation"
			sleep 60
			elapse+=60

			if [ $elapse -gt $(( 60 * 30 )) ]
			then
				echo "* [tls] ERROR: DNS propagation timeout (30 minutes)"
				exit 1
			fi
		done
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

			"$FLAP_DIR/system/cli/lib/tls/update/${provider}.sh" "$domain"
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
        echo "domains | [handle_request, list, list_all, primary, help] | Toolbox to manage domains."
        ;;
    help|*)
        echo "
$(flapctl domains summarize)
Commands:
	handle_request | | Handle domain requests in the file system.
	register_domain | | Register a domain if necessary.
	update_dns_records | | Update DNS records for all OK domains.
    list | | Show the full list of domain names and their information.
    list_all | | Same as 'list' but with subdomains.
    primary | | Show the primary domain name." | column -t -s "|"
        ;;
esac
