#!/bin/bash

set -eu

# shellcheck disable=SC2002
local_dkim=$(cat "$FLAP_DIR/mail/config/opendkim/keys/$PRIMARY_DOMAIN_NAME/mail.txt" | tr "\n" " " | grep --only-matching --extended-regexp 'p=.+"' | tr '"\t' ' ' | sed 's/[[:space:]]//g')
dns_dkim=$(dig mail._domainkey."$PRIMARY_DOMAIN_NAME" txt | grep '^[^;]')

if [[ "$local_dkim" != "$dns_dkim" ]]
then
	echo "- Local and DNS DKIM are not the same."
	echo "	- Local: $local_dkim."
	echo "	- DNS: $dns_dkim."
	exit_code=1
fi

exit $exit_code