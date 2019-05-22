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
    $(dirname "$0")/localhost_auth_hook.sh $DOMAIN_NAME
else
    manager ports open 8443
    manager ports open 8080

    certbot certonly \
        --standalone \
        --tls-sni-01-port 8443 \
        --http-01-port 8080 \
        --agree-tos \
        --email louis@chmn.me \
        --domain $DOMAIN_NAME

    manager ports close 8443
    manager ports close 8080

    certbot certonly \
        --non-interactive \
        --manual \
        --preferred-challenges dns \
        --agree-tos \
        --email louis@chmn.me \
        --manual-auth-hook "$(dirname "$0")/${PROVIDER}_auth_hook.sh $PROVIDER_ARG" \
        --manual-public-ip-logging-ok \
        --domain *.$DOMAIN_NAME

    # Nginx config for services expect dedicated ssl files
    # ROOT
    cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem /etc/ssl/nginx/$DOMAIN_NAME.crt
    cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem /etc/ssl/nginx/$DOMAIN_NAME.key
    # NEXTCLOUD
    cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem /etc/ssl/nginx/files.$DOMAIN_NAME.crt
    cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem /etc/ssl/nginx/files.$DOMAIN_NAME.key
    # SOGO
    cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem /etc/ssl/nginx/sogo.$DOMAIN_NAME.crt
    cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem /etc/ssl/nginx/sogo.$DOMAIN_NAME.key
fi
