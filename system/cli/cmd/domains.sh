#!/bin/bash

set -euo pipefail

CMD=${1:-}

# Make sure the domains folder exists
mkdir -p "$FLAP_DATA/system/data/domains"

case $CMD in
	add)
		domainname=$2

		echo "Add domain $domainname ? [Y/N]:"
		read -r answer

		if [ "$answer" == "${answer#[Yy]}" ]
		then
			exit 0
		fi

		{
			wget \
				--method POST \
				--header 'Host: flap.local' \
				--header 'Content-Type: application/json' \
				--body-data "{ \"name\": \"$domainname\", \"provider\": \"unknown\" }" \
				--quiet \
				--output-document=- \
				--content-on-error \
				http://localhost/api/domains
		} || {
			echo "Could not the contact home docker container, make sure your containers are up."
			exit 1
		}

		flapctl domains handle_request

		echo ""
		echo "* [users] The domain '$domainname was added."
		;;
	delete)
		domainname=$2

		echo "Do you really want to delete $domainname, make sure no services depend on it ? [Y/N]:"
		read -r answer

		if [ "$answer" == "${answer#[Yy]}" ]
		then
			exit 0
		fi

		# Unset the domain as primary if needed.
		if [ "$(flapctl domains primary)" == "$domainname" ]
		then
			echo "" > "$FLAP_DATA/system/data/primary_domain.txt"
		fi

		rm -rf "$FLAP_DATA/system/data/domains/$domainname"

		touch "$FLAP_DATA/system/data/domain_update_delete.txt"

		flapctl domains handle_request
		;;
	generate_local)
		domain=${2:-flap.test}

		# Create default flap.test domain if it is missing.
		mkdir -p "$FLAP_DATA/system/data/domains/$domain"
		echo "WAITING" > "$FLAP_DATA/system/data/domains/$domain/status.txt"
		echo "local" > "$FLAP_DATA/system/data/domains/$domain/provider.txt"
		touch "$FLAP_DATA/system/data/domains/$domain/authentication.txt"
		touch "$FLAP_DATA/system/data/domains/$domain/logs.txt"

		flapctl domains handle_request
		;;
	handle_request)
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

		echo '* [domains] Handling domain update request'
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

		echo '* [domains] Handling domain delete request'
		# Handle domain deletion request
		{
			echo "HANDLED" > "$FLAP_DATA/system/data/domain_update_delete.txt" &&
			flapctl tls generate &&
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
				waiting_domain=$(basename "$domain")
				echo "HANDLED" > "$domain/status.txt"
				break
			fi
		done

		# If there was no WAITING domain, exit
		if [ -z "${waiting_domain:-}" ]
		then
			exit 0
		fi

		echo '* [domains] Handling domain create request'

		# Give time to the server to pick up the status change.
		sleep 2

		{
			{
				if [ "$(flapctl domains primary)" == "" ]
				then
					echo "* [domains] Set $waiting_domain as primary."
					echo "$waiting_domain" > "$FLAP_DATA/system/data/primary_domain.txt"
				fi
			} &&

			flapctl domains register_domain "$waiting_domain" &&
			flapctl tls generate &&

			echo "OK" > "$FLAP_DATA/system/data/domains/$waiting_domain/status.txt" &&

			echo "* [domains] Restarting services after domain creation." &&
			mapfile -t flap_services < <(echo "${FLAP_SERVICES:-}") &&
			flapctl restart &&
			flapctl hooks post_domain_update "${flap_services[@]}"
		} || { # Catch error
			echo "Failed to handle domain request."

			echo "ERROR" > "$FLAP_DATA/system/data/domains/$waiting_domain/status.txt"

			# Unset the domain as primary if needed.
			if [ "$(flapctl domains primary)" == "$waiting_domain" ]
			then
				echo "" > "$FLAP_DATA/system/data/primary_domain.txt"
			fi

			# Generate certificates if they were remove.
			if [ ! -d /etc/letsencrypt/live/flap ]
			then
				flapctl tls generate
			fi

			exit 1
		}
		;;
	register_domain)
		domain=${2:-}

		if [ "$domain" == "" ]
		then
			exit 0
		fi

		provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")

		if [ -f "$FLAP_DIR/system/cli/lib/tls/register/$provider.sh" ]
		then
			echo "* [domains] Registering domain name."

			"$FLAP_DIR/system/cli/lib/tls/register/$provider.sh" "$domain"
			"$FLAP_DIR/system/cli/lib/tls/update/$provider.sh" "$domain"
		fi

		# We don't need to wait for the domain to point to the server for local domains.
		if [ "$provider" == "localhost" ] || [ "$provider" == "local" ]
		then
			exit 0;
		fi

		elapse=0
		until [ "$(flapctl ip dns "$domain")" == "$(flapctl ip external)" ] > /dev/null
		do
			echo "Waiting for DNS propagation"
			sleep 60
			((elapse+=60))

			if [ "$elapse" -gt $(( 60 * 30 )) ]
			then
				echo "* [domains] ERROR: DNS propagation timeout (30 minutes)"
				exit 1
			fi
		done
		;;
	update_dns_records)
		if [ "${FLAG_NO_DNS_RECORD_UPDATE:-}" == "true" ]
		then
			exit
		fi

		# Get current external IP to check if it is necessary to update the DNS.
		external_ip=$(flapctl ip external)

		# Execute update script for each OK domain or the provided ones.
		read -r -a domains <<< "$DOMAIN_NAMES"

		if [ "$#" -gt "1" ]
		then
			domains=("$@")
			domains=("${domains[@]:1}")
		fi

		for domain in "${domains[@]}"
		do
			provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")

			# Do not try to update DNS records for local or localhost domains.
			if [ "$provider" == "localhost" ] || [ "$provider" == "local" ]
			then
				continue
			fi

			# Do not update DNS records if the ip is correct.
			host_ip=$(flapctl ip dns "$domain")
			if [ "$external_ip" == "$host_ip" ] || ! echo "$host_ip" | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$"
			then
				continue
			fi

			echo "* [domains:$domain] Updating, $external_ip != $host_ip."

			"$FLAP_DIR/system/cli/lib/tls/update/$provider.sh" "$domain"
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
		echo "domains | [add, generate_local, handle_request, register_domain, update_dns_records, list, list_all, primary, help] | Toolbox to manage domains."
		;;
	help|*)
		echo "
$(flapctl domains summarize)
Commands:
	add | | Start domain creation form.
	generate_local | [<domain_name>] | Generate local domain for development.
	handle_request | | Handle domain requests in the file system.
	register_domain | | Register a domain if necessary.
	update_dns_records | | Update DNS records for all OK domains.
	list | | Show the full list of domain names and their information.
	list_all | | Same as 'list' but with subdomains.
	primary | | Show the primary domain name." | column -t -s "|"
		;;
esac
