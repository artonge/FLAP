#!/bin/bash

set -euo pipefail


# Start ldap server.
docker-compose up -d ldap

# Get list of users's usernames.
users=$(
    docker-compose exec ldap ldapsearch \
        -x \
        -D cn=admin,dc=flap,dc=local \
        -w "$ADMIN_PWD" \
        -b 'ou=users,dc=flap,dc=local' \
        'objectClass=person' | \
    grep 'sn:' | \
    cut -d ' ' -f2
)

# for each username, update the user's dn.
for username in $users
do
    echo "Updating $username"

    echo "dn: sn=$username,ou=users,dc=flap,dc=local
changetype: moddn
newrdn: uid=$username
deleteoldrdn: 0" | \
docker-compose exec -T ldap \
    ldapmodify \
        -x \
        -D cn=admin,dc=flap,dc=local \
        -w "$ADMIN_PWD" || true
done

# Stop ldap server.
docker-compose down
