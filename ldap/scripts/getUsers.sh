#!/bin/bash

set -e

# -x Simple authentication
# -b Use searchbase as the starting point for the search instead of the default
# -D binddn  bind DN
# -w passwd  bind password (for simple authentication)
docker-compose exec ldap ldapsearch \
	-x \
	-b dc=flap,dc=local \
	-D cn=admin,dc=flap,dc=local \
	-w admin
