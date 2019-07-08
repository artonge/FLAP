#!/bin/bash

set -eu

# Usage: ./generate_certs.sh <domain name> [<domain name>, ...]

echo "Generating certificates for $@"

domains=""
for domain in $@
do
    domains+="--domain $domain "
    domains+="--domain files.$domain "
    domains+="--domain sogo.$domain "
done

# Generate certificates for all domains using certbot.
# https://certbot.eff.org/docs/using.html#standalone
# --expand - allow to merge new domains to the existing ones in the same certificates.
# --force-renewal - prevent certbot return 1 when the certificates is already generated.
certbot certonly \
    --non-interactive \
    --standalone \
    --expand \
    --force-renewal \
    --agree-tos \
    --email louis@chmn.me \
    $domains

# Copy certificates to the nginx folder.
mkdir -p /etc/ssl/nginx
cp /etc/letsencrypt/live/$1/fullchain.pem /etc/ssl/nginx/fullchain.crt
cp /etc/letsencrypt/live/$1/privkey.pem /etc/ssl/nginx/privkey.key
cp /etc/letsencrypt/live/$1/chain.pem /etc/ssl/nginx/chain.pem
