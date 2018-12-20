#!/bin/bash

set -e

ORGANISATION_NAME=$1

# -x         Simple authentication
# -D binddn  bind DN
# -w passwd  bind password (for simple authentication)
echo "# USER ENTRY
dn: ou=$ORGANISATION_NAME,dc=flap,dc=local
ou: $ORGANISATION_NAME
objectClass: organizationalUnit
" |
docker-compose exec -T ldap ldapadd \
	-x \
	-D cn=admin,dc=flap,dc=local \
	-w admin
