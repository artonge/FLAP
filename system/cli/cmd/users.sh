#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	"")
		cd $FLAP_DIR

		# Start an ldap instance and redirect the output to null.
		docker-compose run --detach --name flap_tmp_ldap ldap &> /dev/null

		users=$(docker-compose run --rm ldap slapcat | \
		grep '^uid:' | \
		cut -d ' ' -f2 2> /dev/null)

		# Stop and remove the ldap instance and redirect the output to null.
		docker stop flap_tmp_ldap > /dev/null
		docker rm flap_tmp_ldap > /dev/null

		# Remove \r char.
		echo ${users//[$'\r']}
		;;
	summarize)
		echo "users | | List users."
		;;
	help|*)
		flapctl users summarize
		;;
esac
