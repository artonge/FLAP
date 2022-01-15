#!/bin/bash

set -euo pipefail


debug "Generate DKIM."
rm -rf "$FLAP_DIR/mail/config/opendkim"
echo "" > "$FLAP_DIR/mail/config/vhost.dkim.tmp"
for domain in $DOMAIN_NAMES
do
    echo "$domain" >> "$FLAP_DIR/mail/config/vhost.dkim.tmp"
done
docker-compose exec -T mail cp /tmp/docker-mailserver/vhost.dkim.tmp /tmp/vhost.dkim.tmp
docker-compose exec -T mail open-dkim
# Give read rights to group and other for public keys.
chmod go+r "$FLAP_DIR"/mail/config/opendkim/keys/*/*.txt

debug "Update DNS records."
flapctl domains update_dns_records

debug "Update smtp senders map."
flapctl users sync_mail_aliases
flapctl exec mail generate_smtp_senders_map
