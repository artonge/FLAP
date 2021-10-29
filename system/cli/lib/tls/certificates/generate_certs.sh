#!/bin/bash

set -eu

# Usage: ./generate_certs.sh <domain name> [<domain name>, ...]

echo "* Generating certificates for $*"

domains=()
for domain in "$@"
do
    domains+=(--domain "$domain")
    for subdomain in $SUBDOMAINS
    do
        domains+=(--domain "$subdomain.$domain ")
    done
done

# Dry run first.
certbot certonly \
    --dry-run \
    --rsa-key-size 4096 \
    --cert-name flap \
    --non-interactive \
    --standalone \
    --expand \
    --force-renewal \
    --agree-tos \
    --email "$ADMIN_EMAIL" \
    "${domains[@]}"

if [ -d /etc/letsencrypt/live/flap ]
then
    certbot delete --cert-name flap
fi

# Generate certificates for all domains using certbot.
# https://certbot.eff.org/docs/using.html#standalone
# --cert-name - set the name of the folder where the certificates will be stored \
# --expand - allow to merge new domains to the existing ones in the same certificates.
# --force-renewal - prevent certbot return 1 when the certificates is already generated.
certbot certonly \
    --rsa-key-size 4096 \
    --cert-name flap \
    --non-interactive \
    --standalone \
    --expand \
    --force-renewal \
    --agree-tos \
    --email "$ADMIN_EMAIL" \
    "${domains[@]}"
