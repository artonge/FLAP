#!/bin/bash

set -eu

CMD=${1:-}

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

		# Exit now if there is no domains to setup.
		if [ ${#domains[@]} == "0" ]
		then
			exit 0
		fi

		{
			# Generate TLS certificates
			"$FLAP_DIR/system/cli/lib/tls/certificates/generate_certs.sh" "${domains[@]}"
		} || { # Catch error
			echo "Failed to generate certificates."
			exit 1
		}
		;;
	generate_localhost)
		domain=${2:-flap.test}
		cert_path=/etc/letsencrypt/live/flap

		# Create default flap.test domain if it is missing
		mkdir -p "$FLAP_DATA/system/data/domains/$domain"
		echo "OK" > "$FLAP_DATA/system/data/domains/$domain/status.txt"
		echo "local" > "$FLAP_DATA/system/data/domains/$domain/provider.txt"
		touch "$FLAP_DATA/system/data/domains/$domain/authentication.txt"
		touch "$FLAP_DATA/system/data/domains/$domain/logs.txt"
		
		# Resource load_env_vars to refresh $SUBDOMAINS
		# Load feature flags and services environment variables.
		# shellcheck source=system/cli/lib/load_env_vars.sh
		source "$FLAP_LIBS/load_env_vars.sh"

		echo "* [tls] Generating certificates for $domain"

		mkdir -p "$cert_path"

		# Write root CA configuration file.
		echo "[ req ]
prompt             = no
string_mask        = default
default_bits       = 2048
distinguished_name = req_distinguished_name
x509_extensions    = x509_ext
[ req_distinguished_name ]
organizationName = FLAP
commonName = FLAP local Root CA
[ x509_ext ]
basicConstraints=critical,CA:true,pathlen:0
keyUsage=critical,keyCertSign,cRLSign" > "$cert_path/root_ca.conf"

		# Prevent overriding existing root CA.
		if [ ! -f "$cert_path/root.cer" ]
		then
			# Creating root CA.
			openssl req \
				-days 3650 \
				-nodes \
				-x509 \
				-new \
				-keyout "$cert_path/root.key" \
				-out "$cert_path/root.cer" \
				-config "$cert_path/root_ca.conf"
		fi

		# Write certificates configuration file.
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
DNS.1 = $domain" > "$cert_path/server_cert.conf"

		# Add all subdomains to the server_cert.conf file.
		# shellcheck disable=SC2153
		read -r -a subdomains <<< "$SUBDOMAINS"
		subdomains+=(lemon)
		for i in "${!subdomains[@]}"
		do
			echo "DNS.$((i + 2)) = ${subdomains[$i]}.$domain" >> "$cert_path/server_cert.conf"
		done

		# Generating TLS certificate.
		openssl req \
			-days 3650 \
			-nodes \
			-new \
			-keyout "$cert_path/server.key" \
			-out "$cert_path/server.csr" \
			-config "$cert_path/server_cert.conf"

		# Signing certificate with root CA.
		openssl x509 \
			-days 3650 \
			-req \
			-in "$cert_path/server.csr" \
			-CA "$cert_path/root.cer" \
			-CAkey "$cert_path/root.key" \
			-set_serial "$RANDOM" \
			-out "$cert_path/server.cer" \
			-extfile "$cert_path/server_cert.conf" \
			-extensions x509_ext

		# Copy certificates to Nginx exploitable files.
		cp "$cert_path/server.cer" "$cert_path/fullchain.pem"
		cp "$cert_path/server.key" "$cert_path/privkey.pem"
		cp "$cert_path/root.cer" "$cert_path/chain.pem"

		# Setup primary domain.
		echo "$domain" > "$FLAP_DATA/system/data/primary_domain.txt"

		echo ""
		echo "You can install the following CA in your browser to ease development: $cert_path/root.cer"
		;;
	summarize)
		echo "tls | [generate, generate_localhost, help] | Manage TLS certificates."
		;;
	help|*)
		echo "
$(flapctl tls summarize)
Commands:
    generate | | Generate certificates for the current domain name.
    generate_localhost | | Create flap.test domain and generate certificates if none exists." | column -t -s "|"
        ;;
esac
