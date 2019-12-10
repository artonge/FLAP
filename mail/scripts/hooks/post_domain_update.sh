#!/bin/bash

set -eu

# Generate DKIM.
docker-compose exec -T mail rm -rf $FLAP_DIR/mail/config/vhost.tmp
for domain in $DOMAIN_NAMES
do
    echo $DOMAIN_NAMES >> $FLAP_DIR/mail/config/vhost.tmp
    docker-compose exec -T mail cp /tmp/docker-mailserver/vhost.tmp /tmp/vhost.tmp
done
docker-compose exec -T mail generate-dkim-config

# Update DNS records.
manager tls update_dns_records