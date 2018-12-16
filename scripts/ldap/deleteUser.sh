#!/bin/bash

set -e

USER_NAME=$1

# -x         Simple authentication
# -D binddn  bind DN
# -w passwd  bind password (for simple authentication)
docker-compose exec -T ldap ldapdelete \
	-x \
	-D "cn=admin,dc=flap,dc=local" \
	-w admin \
	sn=$USER_NAME,ou=users,dc=flap,dc=local
