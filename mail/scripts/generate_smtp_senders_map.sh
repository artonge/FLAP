#!/bin/bash

set -eu

echo 'Generate authorized smtp senders map.'

echo "" > "$FLAP_DIR/mail/config/smtpd_sender"

if [ "$PRIMARY_DOMAIN_NAME" == "" ]
then
	exit 0
fi

mapfile -t users < <(flapctl users list | grep -v '^admin$')

for user in "${users[@]}"
do
	mapfile -t aliases < <(flapctl users list_mail_aliases "$user")

	echo "- $user"

	for alias in "${aliases[@]}"
	do
		echo "	$alias"
		echo "$alias $user@$PRIMARY_DOMAIN_NAME" >> "$FLAP_DIR/mail/config/smtpd_sender"
	done
done

# Add addresses for admin.
echo "- admin"
for domain in $DOMAIN_NAMES
do
	echo "	admin@$domain"
	echo "admin@$domain admin@$PRIMARY_DOMAIN_NAME" >> "$FLAP_DIR/mail/config/smtpd_sender"
done
