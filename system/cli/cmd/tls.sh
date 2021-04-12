#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	generate)
		echo '* [tls] Generating certificates for domain names.'

		# Filter domains that are either OK or HANDLED and not for "local" or "localhost".
		domains=()
		locals_domains=()
		for domain in "$FLAP_DATA"/system/data/domains/*
		do
			[[ -e "$domain" ]] || break  # handle the case of no domain.

			status=$(cat "$domain/status.txt")
			provider=$(cat "$domain/provider.txt")

			if [ "$status" == "OK" ] || [ "$status" == "HANDLED" ]
			then
				if [ "$provider" != "localhost" ] && [ "$provider" != "local" ]
				then
					domains+=("$(basename "$domain")")
				else
					locals_domains+=("$(basename "$domain")")
				fi
			fi
		done

		# Generate TLS certificates for domains.
		if [ ${#domains[@]} != "0" ] && [ "${FLAG_NO_TLS_GENERATION:-}" != "true" ]
		then
			{			
				flapctl stop nginx &&
				"$FLAP_DIR/system/cli/lib/tls/certificates/generate_certs.sh" "${domains[@]}" &&
				flapctl start nginx
			} || { # Catch error
				echo "Failed to generate certificates."
				exit 1
			}
		fi

		# Generate TLS certificates for locals domains.
		if [ ${#locals_domains[@]} != "0" ]
		then
			flapctl tls generate_local_certs "${locals_domains[@]}"
		fi
		;;
	generate_local_certs)
		domains=("$@")
		domains=("${domains[@]:1}")

		cert_path=/etc/letsencrypt/live/flap

		echo "* [tls] Generating certificates for ${domains[*]}"

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
commonName = ${domains[0]}
[ x509_ext ]
keyUsage=critical,digitalSignature,keyAgreement
subjectAltName = @alt_names
[alt_names]" > "$cert_path/server_cert.conf"

		# Add all subdomains to the server_cert.conf file.
		# shellcheck disable=SC2153
		read -r -a subdomains <<< "$SUBDOMAINS"
		subdomains+=(lemon)

		for i in "${!domains[@]}"
		do
			base=$((i * (${#subdomains[@]} + 1) + 1))
			echo "DNS.$base = ${domains[$i]}" >> "$cert_path/server_cert.conf"

			for j in "${!subdomains[@]}"
			do
				echo "DNS.$((base + j + 1)) = ${subdomains[$j]}.${domains[$i]}" >> "$cert_path/server_cert.conf"
			done
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

		echo ""
		echo "You can install the following CA in your browser to ease development: $cert_path/root.cer"
		;;
	summarize)
		echo "tls | [generate, generate_local_certs, help] | Manage TLS certificates."
		;;
	help|*)
		echo "
$(flapctl tls summarize)
Commands:
	generate | | Generate certificates for the current domain name.
	generate_local_certs | | Generate certificates if none exists." | column -t -s "|"
		;;
esac
