#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	create_admin)
		# HACK: wget output does not contain a new line, so the log is weird.
		# We can not exec an 'echo ""' because when it fails the script return ealry.
		# We add a `| cat` to prevent exiting early on error.
		# Then we catch the error code with PIPESTATUS, exec `echo ""` and return the exit code.
		wget \
			--method POST \
			--header "Content-Type: application/json" \
			--body-data '{
					"username": "theadmin",
					"password": "password",
					"fullname": "Mr. Admin",
					"email": "ad@m.in",
					"admin": true
				}' \
			--quiet \
			--output-document=- \
			--content-on-error \
			http://flap.local/api/users | cat

		# Catch error code
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" != "0" ]
		then
			echo ""
			exit "$exit_code"
		fi

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
