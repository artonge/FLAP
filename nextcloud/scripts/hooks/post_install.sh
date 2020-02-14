#!/bin/bash

set -eu

# Generate SAML keys for Netcloud.
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

# Allow nextcloud container's www-data user to read the key.
chmod og+r "$FLAP_DATA/nextcloud/saml/private_key.pem"

# Wait for nextcloud to be ready
"$FLAP_DIR/nextcloud/scripts/wait_ready.sh"

# Run post install script for nextcloud.
docker-compose exec -T nextcloud chown www-data:www-data /data
docker-compose exec -T nextcloud touch /data/.ocdata

# Generate config.php with the config.
docker-compose exec -T --user www-data nextcloud /inner_scripts/generate_initial_config.sh
