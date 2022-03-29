#!/bin/bash

set -euo pipefail


debug 'Generate authorized smtp senders map.'

echo "" > "$FLAP_DIR/mail/config/smtpd_sender"

if [ "$PRIMARY_DOMAIN_NAME" == "" ]
then
	exit 0
fi

mapfile -t users < <(flapctl users list | grep -v '^admin$')

for user in "${users[@]}"
do
	mapfile -t aliases < <(flapctl users list_mail_aliases "$user")

	debug "- $user"

	for alias in "${aliases[@]}"
	do
		debug "	- $alias"
		echo "$alias $user@$PRIMARY_DOMAIN_NAME" >> "$FLAP_DIR/mail/config/smtpd_sender"
	done
done

# Add addresses for admin.
debug "- admin"
for domain in $DOMAIN_NAMES
do
	debug "	admin@$domain"
	echo "admin@$domain admin@$PRIMARY_DOMAIN_NAME" >> "$FLAP_DIR/mail/config/smtpd_sender"
done
