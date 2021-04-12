#!/bin/bash

set -eu

echo "Generating SAML keys."
mkdir -p "$FLAP_DATA/matrix/saml"
openssl req \
    -new \
    -newkey rsa:4096 \
    -keyout "$FLAP_DATA/matrix/saml/private_key.pem" \
    -nodes  \
    -out "$FLAP_DATA/matrix/saml/cert.pem" \
    -x509 \
    -days 3650 \
    -subj "/"

echo "Changing private key rights to allow synapse process to read it."
chmod og+r "$FLAP_DATA/matrix/saml/private_key.pem"

flapctl hooks post_domain_update matrix
