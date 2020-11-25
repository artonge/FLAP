#!/bin/bash

set -eu

# Update matomo users access rights depending on theirs FLAP admin status.

docker-compose ps --filter State=up | grep -E "^flap_ldap " | cat &> /dev/null
was_up=${PIPESTATUS[1]}

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

if [ "$was_up" != "0" ]
then
	# Remove networks.
	flapctl hooks clean system &> /dev/null
fi
