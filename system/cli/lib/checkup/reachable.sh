#!/bin/bash

set -eu

exit_code=0

if [ "$PRIMARY_DOMAIN_NAME" != "" ]
then
	exit 0
fi

if [ "$(flapctl ip dns "$PRIMARY_DOMAIN_NAME")" == "$(flapctl ip external)" ]
then
	echo "- The domain name is not pointing to this server."
	exit_code=1
fi

exit "$exit_code"
