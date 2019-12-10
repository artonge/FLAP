#!/bin/bash

set -eu

# Generate DKIM.
echo "" >> $FLAP_DIR/mail/config/vhost.tmp
for domain in $DOMAIN_NAMES
do
    echo $domain >> $FLAP_DIR/mail/config/vhost.tmp
done
docker-compose exec -T mail cp /tmp/docker-mailserver/vhost.tmp /tmp/vhost.tmp
docker-compose exec -T mail generate-dkim-config

# Update DNS records.
manager tls update_dns_records
