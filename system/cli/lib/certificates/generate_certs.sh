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
