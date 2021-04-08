#!/bin/bash

set -eu

echo "Add services' custom config to the postfix-main config."
for service in $FLAP_SERVICES
do
	# Check if a 'postfix-main-extra.cf' file exists for the service.
	if [ -f "$FLAP_DIR/$service/config/postfix-main-extra.cf" ]
	then
		cat "$FLAP_DIR/$service/config/postfix-main-extra.cf" >> "$FLAP_DIR/mail/config/postfix-main.cf"
	fi
done
