#!/bin/bash

set -e

USER_NAME=$1
USER_FULL_NAME=$2

# -x         Simple authentication
# -D binddn  bind DN
# -w passwd  bind password (for simple authentication)
echo "# USER ENTRY
dn: ou=users,dc=flap,dc=local
ou: users
objectClass: organizationalUnit
" |
docker-compose exec -T ldap ldapadd \
	-x \
	-D cn=admin,dc=flap,dc=local \
	-w admin
