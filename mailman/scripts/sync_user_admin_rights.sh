#!/bin/bash

set -euo pipefail

# Update mailman users access rights depending on theirs FLAP admin status.

if ! is_service_up ldap
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
		docker compose run --no-deps --rm ldap slapcat -a "(uid=$username)" 2> /dev/null | \
		grep '^objectClass: organizationalPerson' | \
		cat
	)

	if [ "$admin_access" == "" ]
	then
		admin_access=FALSE
	else
		admin_access=TRUE
	fi

	if [ "${FLAP_DEBUG:-}" != "true" ]
	then
		args=(--quiet)
	fi

	docker compose exec -T --user postgres postgres psql "${args[@]}" mailman -c "UPDATE auth_user SET is_superuser='$admin_access' WHERE username='$username';"

done
