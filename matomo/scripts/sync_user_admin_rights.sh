#!/bin/bash

set -eu

# Update matomo users access rights depending on theirs FLAP admin status.

if ! docker-compose ps --filter State=up | grep --quiet -E "^flap_ldap "
then
	exit
fi

for username in $(flapctl users list)
do
	if [ "$username" == "admin" ]
	then
		continue
	fi

	admin_access=$(
		docker-compose run --no-deps --rm ldap slapcat -a "(uid=$username)" 2> /dev/null | \
		grep '^objectClass: organizationalPerson' | \
		cat
	)

	if [ "$admin_access" == "" ]
	then
		admin_access=0
	else
		admin_access=1
	fi

	docker-compose exec -T mariadb mysql \
	 	--password="$ADMIN_PWD" \
		--database "matomo" \
		--execute "UPDATE user SET superuser_access='$admin_access' WHERE login='$username';"
done
