#!/bin/bash

set -eu

# Generate DKIM.
rm -rf "$FLAP_DIR/mail/config/opendkim"
echo "" > "$FLAP_DIR/mail/config/vhost.tmp"
for domain in $DOMAIN_NAMES
do
    echo "$domain" >> "$FLAP_DIR/mail/config/vhost.tmp"
done
docker-compose exec -T mail cp /tmp/docker-mailserver/vhost.tmp /tmp/vhost.tmp
docker-compose exec -T mail generate-dkim-config

# Update DNS records.
flapctl domains update_dns_records

# Generate smtpd sender list.
flapctl hooks generate_config mail
