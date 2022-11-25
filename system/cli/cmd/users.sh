#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	create_admin)
		{
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
				http://localhost/api/users
		} || {
			# Improve output by echoing an empty line.
			echo ""
			exit 1
		}

		# Add content to SOGo so pre_backup hooks does not fails.
		if [ "${ENABLE_SOGO:-false}" == "true" ]
		then
			docker exec flap_sogo sogo-tool create-folder theadmin Calendar TestCalendar
		fi

		# Sync nextcloud user base.
		if [ "${ENABLE_NEXTCLOUD:-false}" == "true" ]
		then
			docker exec --user www-data flap_nextcloud php occ user:list
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

		{
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
				http://localhost/api/users
		} || {
			# Improve output by echoing an empty line.
			echo ""
			exit 1
		}

		echo "* [users] The user '$username was created."
		;;
	sync_mail_aliases)
		{
			wget \
				--method GET \
				--header "Host: flap.local" \
				--quiet \
				--output-document=- \
				--content-on-error \
				http://localhost/api/crons/update-mail-aliases
		} || {
			# Improve output by echoing an empty line.
			echo ""
			exit 1
		}
		;;
	list)
		cd "$FLAP_DIR"

		users=$(
			docker compose exec ldap slapcat 2> /dev/null | \
			grep '^uid:' | \
			cut -d ' ' -f2 2> /dev/null
		)

		# Remove \r char.
		echo "${users//[$'\r']}"
		;;
	list_mail_aliases)
		uid=$2

		cd "$FLAP_DIR"

		docker compose exec ldap slapcat -a "uid=$uid" 2> /dev/null > /tmp/export.ldif

		aliases=$(
			{ grep '^mailAlias: ' /tmp/export.ldif || true; } | \
			cut -d ' ' -f2 2> /dev/null
		)

		aliases_base64=$(
			grep '^mailAlias:: ' /tmp/export.ldif | \
			cut -d ' ' -f2 | \
			base64 --decode --ignore-garbage | \
			tr " " "\n" 2> /dev/null
		)

		# Remove \r char.
		echo "${aliases//[$'\r']}$aliases_base64"
		;;
	summarize)
		echo "users | [list, create_admin] | Manage users."
		;;
	help|*)
		echo "
$(flapctl users summarize)
Commands:
	create | | Tool to create the first user on an instance.
	list | | List existing users." | column -t -s "|"
		;;
esac
