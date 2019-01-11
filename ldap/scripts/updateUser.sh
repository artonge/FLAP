#!/bin/bash

set -e

USER_NAME=$1
FIELD=$2
NEW_VALUE=$3

# -x         Simple authentication
# -D binddn  bind DN
# -w passwd  bind password (for simple authentication)
# http://www.openldap.org/software//man.cgi?query=ldapmodify&sektion=1&apropos=0&manpath=OpenLDAP+2.4-Release
echo "# USER ENTRY
dn: sn=$USER_NAME,ou=users,dc=flap,dc=local
changetype: modify
replace: $FIELD
$FIELD: $NEW_VALUE
" |
docker-compose exec -T ldap ldapmodify \
	-x \
	-D cn=admin,dc=flap,dc=local \
	-w admin
