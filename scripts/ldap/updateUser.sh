#!/bin/bash

set -e

USER_NAME=$1
USER_FULL_NAME=$2

# -x         Simple authentication
# -w passwd  bind password (for simple authentication)
# -D binddn  bind DN
echo "# USER ENTRY
dn: sn=$USER_NAME,ou=users,dc=flap,dc=local
cn: $USER_FULL_NAME
sn: $USER_NAME
objectClass: person
" |
docker-compose exec -T ldap ldapmodify \
	-x \
	-D cn=admin,dc=flap,dc=local \
	-w admin
