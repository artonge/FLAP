#!/bin/bash

set -euo pipefail


# Start ldap server.
docker-compose up -d ldap

flapctl hooks post_install ldap

# Stop ldap server.
docker-compose down

# Run ldap indexer to index mails.
docker-compose run --rm -T -u openldap ldap \
	slapindex -F /etc/ldap/slapd.d/
