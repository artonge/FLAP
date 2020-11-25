#!/bin/bash

set -eu

echo "Generating SAML key for peertube."
mkdir -p "$FLAP_DATA/peertube/saml"
openssl req \
    -new \
    -newkey rsa:4096 \
    -keyout "$FLAP_DATA/peertube/saml/private_key.pem" \
    -nodes  \
    -out "$FLAP_DATA/peertube/saml/cert.pem" \
    -x509 \
    -days 3650 \
    -subj "/"
# Allow peertube user to read the key.
chmod og+r "$FLAP_DATA/peertube/saml/private_key.pem"
