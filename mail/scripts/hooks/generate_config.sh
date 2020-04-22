#!/bin/bash

set -eu

echo 'Generate authorized smtp senders map.'

echo "" > "$FLAP_DIR/mail/config/smtpd_sender"

if [ "$PRIMARY_DOMAIN_NAME" == "" ]
then
	exit 0
fi

mapfile -t users < <(flapctl users list)
for username in "${users[@]}"
do
	# shellcheck disable=SC2153
	for domain in $DOMAIN_NAMES
	do
		echo "- $username@$domain"
		echo "$username@$domain $username@$PRIMARY_DOMAIN_NAME" >> "$FLAP_DIR/mail/config/smtpd_sender"
	done
done
