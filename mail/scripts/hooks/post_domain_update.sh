#!/bin/bash

set -eu

debug "Generate DKIM."
rm -rf "$FLAP_DIR/mail/config/opendkim"
echo "" > "$FLAP_DIR/mail/config/vhost.tmp"
for domain in $DOMAIN_NAMES
do
    echo "$domain" >> "$FLAP_DIR/mail/config/vhost.tmp"
done
docker-compose exec -T mail cp /tmp/docker-mailserver/vhost.tmp /tmp/vhost.tmp
docker-compose exec -T mail open-dkim

debug "Update DNS records."
flapctl domains update_dns_records

debug "Update smtp senders map."
flapctl users sync_mail_aliases
flapctl exec mail generate_smtp_senders_map
