#!/bin/bash

set -e

# Usage: ./generateWildcardCert.sh <domain name> <provider> <provider arg>

DOMAIN_NAME=$1
PROVIDER=$2
PROVIDER_ARG=$3

echo "Generating certificates for domain $DOMAIN_NAME and provider $PROVIDER"

mkdir -p /etc/ssl/nginx

if [ "$PROVIDER" == "localhost" ] || [ "$PROVIDER" == "local" ]
then
	openssl req -x509 -out /etc/ssl/nginx/fullchain.crt -keyout /etc/ssl/nginx/privkey.key \
			-newkey rsa:2048 -nodes -sha256 \
			-subj "/CN=flap.localhost" -extensions EXT \
			-config <(printf "[dn]\nCN=flap.localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$1\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
else
    certbot certonly \
        --non-interactive \
        --standalone \
        --expand \
        --agree-tos \
        --email louis@chmn.me \
        --domain $DOMAIN_NAME \
        --domain files.$DOMAIN_NAME \
        --domain sogo.$DOMAIN_NAME

    # Nginx config for services expect dedicated ssl files
    # ROOT
    cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem /etc/ssl/nginx/fullchain.crt
    cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem /etc/ssl/nginx/privkey.key
fi
