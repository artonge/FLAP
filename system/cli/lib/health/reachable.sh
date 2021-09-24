#!/bin/bash

set -eu

exit_code=0

if [ "$(flapctl ip dns "$PRIMARY_DOMAIN_NAME")" == "$(flapctl ip external)" ]
then
	echo "- The domain name is not pointing to this server."

	exit_code=1
fi

exit "$exit_code"
