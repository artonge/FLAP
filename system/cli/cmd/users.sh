#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	create_admin)
		curl \
			--header "Content-Type: application/json" \
			--request POST \
			--fail \
			--data '{
					"username": "cooluser",
					"password": "password",
					"fullname": "Mr. Admin",
					"email": "ad@m.in",
					"admin": true
				}' \
			http://flap.local/api/users

		echo "* [users] First user 'admin' was created."
		;;
	list)
		cd "$FLAP_DIR"

		docker-compose ps --filter State=up | grep -E "^flap_ldap " | cat &> /dev/null
		was_up=${PIPESTATUS[1]}

		users=$(
			docker-compose run --no-deps --rm ldap slapcat 2> /dev/null | \
			grep '^uid:' | \
			cut -d ' ' -f2 2> /dev/null
		)

		# Stop and remove the ldap instance and redirect the output to null.
		if [ "$was_up" != "0" ]
		then
			flapctl hooks clean system &> /dev/null
		fi

		# Remove \r char.
		echo "${users//[$'\r']}"
		;;
	summarize)
		echo "users | | Manage users."
		;;
	help|*)
		echo "
$(flapctl users summarize)
Commands:
	create_admin | [<username>] [<password>] [<fullname>] [<email>] [<isAdmin>] | Create first admin.
	list | | List existing users." | column -t -s "|"
		;;
esac
