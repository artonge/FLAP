#!/bin/bash

set -eu

echo "Generating SAML key for nextcloud."
mkdir -p "$FLAP_DATA/nextcloud/saml"
openssl req \
    -new \
    -newkey rsa:4096 \
    -keyout "$FLAP_DATA/nextcloud/saml/private_key.pem" \
    -nodes  \
    -out "$FLAP_DATA/nextcloud/saml/cert.pem" \
    -x509 \
    -days 3650 \
    -subj "/"
# Allow nextcloud user to read the key.
chmod og+r "$FLAP_DATA/nextcloud/saml/private_key.pem"
