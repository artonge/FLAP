#!/bin/bash

set -e

# Usage: ./generate_certs.sh <domain name> [<domain name>, ...]

echo "Generating certificates for $@"

domains=""
for domain in $@
do
    domains+="--domain $domain "
    domains+="--domain files.$domain "
    domains+="--domain sogo.$domain "
done

certbot certonly \
    --non-interactive \
    --standalone \
    --expand \
    --agree-tos \
    --email louis@chmn.me \
    $domains

# Copy certificates to the nginx folder.
mkdir -p /etc/ssl/nginx
cp /etc/letsencrypt/live/$1/fullchain.pem /etc/ssl/nginx/fullchain.crt
cp /etc/letsencrypt/live/$1/privkey.pem /etc/ssl/nginx/privkey.key
cp /etc/letsencrypt/live/$1/chain.pem /etc/ssl/nginx/chain.pem
