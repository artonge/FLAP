#!/bin/bash

set -e

USER_NAME=$1
USER_FULL_NAME=$2
PASSWORD=$3

# -x         Simple authentication
# -D binddn  bind DN
# -w passwd  bind password (for simple authentication)
# http://www.openldap.org/software//man.cgi?query=ldapmodify&sektion=1&apropos=0&manpath=OpenLDAP+2.4-Release
echo "# USER ENTRY
dn: sn=$USER_NAME,ou=users,dc=flap,dc=local
cn: $USER_FULL_NAME
sn: $USER_NAME
userPassword: (blowfish)$PASSWORD
objectClass: person
" |
docker-compose exec -T ldap ldapadd \
	-x \
	-D cn=admin,dc=flap,dc=local \
	-w admin
