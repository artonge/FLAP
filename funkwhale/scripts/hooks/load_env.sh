#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${FUNKWHALE_DB_PWD} \${FUNNKWHALE_DOMAIN_NAME} $\{FUNKWHALE_DJANGO_SECRET_KEY\}"
SUBDOMAINS="$SUBDOMAINS video"

export ENABLE_FUNKWHALE
export FUNNKWHALE_DOMAIN_NAME
export FUNNKWHALE_DB_PWD
export FUNKWHALE_DJANGO_SECRET_KEY

ENABLE_FUNKWHALE=${ENABLE_FUNKWHALE:-false}

FUNNKWHALE_DB_PWD=$(generatePassword funkwhale funkwhale_db_pwd)
FUNKWHALE_DJANGO_SECRET_KEY=$(generatePassword funkwhale funkwhale_django_secret_key)

# Set the funkwhale domain if primary domain is set.
touch "$FLAP_DATA/funkwhale/domain.txt"
FUNNKWHALE_DOMAIN_NAME=$(cat "$FLAP_DATA/funkwhale/domain.txt")
if [ "$FUNNKWHALE_DOMAIN_NAME" == "" ]
then
	FUNNKWHALE_DOMAIN_NAME=$PRIMARY_DOMAIN_NAME
	echo "$FUNNKWHALE_DOMAIN_NAME" > "$FLAP_DATA/funkwhale/domain.txt"
fi
