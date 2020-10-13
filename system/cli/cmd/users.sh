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
			--header "Host: flap.local" \
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
			http://localhost/api/users | cat

		# Catch error code
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" != "0" ]
		then
			echo ""
			exit "$exit_code"
		fi

		echo "* [users] First user 'theadmin'/'password' was created."
		;;
	create)
		echo "Username:"
		read -r username
		echo "Display Name:"
		read -r displayname
		echo "Email:"
		read -r email

		echo "Create admin user $username ($displayname, $email) ? [Y/N]:"
		read -r answer

		if [ "$answer" == "${answer#[Yy]}" ]
		then
			exit 0
		fi

		# HACK: wget output does not contain a new line, so the log is weird.
		# We can not exec an 'echo ""' because when it fails the script return ealry.
		# We add a `| cat` to prevent exiting early on error.
		# Then we catch the error code with PIPESTATUS, exec `echo ""` and return the exit code.
		wget \
			--method POST \
			--header "Content-Type: application/json" \
			--header "Host: flap.local" \
			--body-data "{
					\"username\": \"$username\",
					\"fullname\": \"$displayname\",
					\"email\": \"$email\",
					\"admin\": true
				}" \
			--quiet \
			--output-document=- \
			--content-on-error \
			http://localhost/api/users | cat

		# Catch error code
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" != "0" ]
		then
			echo ""
			exit "$exit_code"
		fi

		echo "* [users] The user '$username was created."
		;;
	sync_mail_aliases)
		wget \
			--method GET \
			--header "Host: flap.local" \
			--quiet \
			--output-document=- \
			--content-on-error \
			http://localhost/api/crons/update-mail-aliases | cat

		# Catch error code
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" != "0" ]
		then
			echo ""
			exit "$exit_code"
		fi
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

		if [ "$was_up" != "0" ]
		then
			# Remove networks.
			flapctl hooks clean system &> /dev/null
		fi

		# Remove \r char.
		echo "${users//[$'\r']}"
		;;
	list_mail_aliases)
		uid=$2

		cd "$FLAP_DIR"

		docker-compose ps --filter State=up | grep -E "^flap_ldap " | cat &> /dev/null
		was_up=${PIPESTATUS[1]}

		docker-compose run --no-deps --rm ldap slapcat -a "uid=$uid" 2> /dev/null > /tmp/export.ldif

		aliases=$(
			grep '^mailAlias: ' /tmp/export.ldif | \
			cut -d ' ' -f2 2> /dev/null
		)

		aliases_base64=$(
			grep '^mailAlias:: ' /tmp/export.ldif | \
			cut -d ' ' -f2 | \
			base64 --decode --ignore-garbage | \
			tr " " "\n" 2> /dev/null
		)

		if [ "$was_up" != "0" ]
		then
			# Remove networks.
			flapctl hooks clean system &> /dev/null
		fi

		# Remove \r char.
		echo "${aliases//[$'\r']}""$aliases_base64"
		;;
	summarize)
		echo "users | [list, create_admin] | Manage users."
		;;
	help|*)
		echo "
$(flapctl users summarize)
Commands:
	create_admin | [<username>] [<password>] [<fullname>] [<email>] [<isAdmin>] | Create first admin.
	list | | List existing users." | column -t -s "|"
		;;
esac
