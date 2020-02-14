#!/bin/bash

set -eu

# Generate SAML keys for Netcloud.
mkdir -p "$FLAP_DATA/nextcloud/saml"
openssl req \
    -new \
    -newkey rsa:4096 \
    -keyout "$FLAP_DATA/nextcloud/saml/private_key.pem" \
    -nodes  \
    -out "$FLAP_DATA"/nextcloud/saml/cert.pem \
    -x509 \
    -days 3650 \
    -subj "/"

# Allow nextcloud container's www-data user to read the key.
chmod og+r "$FLAP_DATA"/nextcloud/saml/private_key.pem


# Migrate user's folders.
# Get list of users's usernames.
users=$(
    docker-compose run --rm ldap slapcat \
        -a  'objectClass=person' | \
    grep 'sn:' | \
    cut -d ' ' -f2 | \
    sed -e 's/[[:space:]]*$/ /'
)

docker-compose up -d postgres

# For each usernames, update the user's folder.
for username in $users
do
    echo "- Updating $username"

    uuid=$(
        docker-compose run --rm ldap slapcat \
            -a  "sn=$username" | \
        grep 'entryUUID:' | \
        cut -d ' ' -f2 | \
        sed -e 's/[[:space:]]*$//'
    )

    echo "UUID is $uuid"

    mv "$FLAP_DATA/nextcloud/data/$uuid" "$FLAP_DATA/nextcloud/data/$username" || true

    docker-compose exec -T postgres psql -U nextcloud -c "UPDATE oc_accounts SET uid = '$username' WHERE uid = '$uuid';"
    docker-compose exec -T postgres psql -U nextcloud -c "UPDATE oc_ldap_user_mapping SET owncloud_name = '$username' WHERE owncloud_name = '$uuid';"
    docker-compose exec -T postgres psql -U nextcloud -c "UPDATE oc_preferences SET userid = '$username' WHERE userid = '$uuid';"
    docker-compose exec -T postgres psql -U nextcloud -c "UPDATE oc_cards_properties SET value = '$username' WHERE value = '$uuid';"
    docker-compose exec -T postgres psql -U nextcloud -c "UPDATE oc_cards_properties SET value = '$username@localhost' WHERE value = '$uuid@localhost';"
done

docker-compose down
