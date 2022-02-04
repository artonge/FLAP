#!/bin/bash

set -euo pipefail


# Version v1.7.2

# Start ldap server.
docker-compose up -d ldap

# Get list of users's usernames.
users=$(flapctl users list | grep -v -E '^admin$')

# for each username, update the user's dn.
for username in $users
do
    echo "* [3] Add objectClass 'PostfixBookMailAccount' to $username"

    echo "dn: uid=$username,ou=users,dc=flap,dc=local
changetype: modify
add: objectClass
objectClass: PostfixBookMailAccount" | \
    docker-compose exec -T ldap \
        ldapmodify \
            -x \
            -D cn=admin,dc=flap,dc=local \
            -w "$ADMIN_PWD"
done

# Stop ldap server.
docker-compose down
