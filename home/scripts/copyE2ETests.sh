#!/bin/bash

set -euo pipefail


rm --force "$FLAP_DIR/home/e2e/tests/services/*"

debug "Copying e2e test files."
for service in $FLAP_SERVICES
do
	if [ "$service" == "home" ]
	then
		continue
	fi

	for e2eTestFile in "$FLAP_DIR/$service"/e2e/*.ts
	do
		[[ -e "$e2eTestFile" ]] || break

		debug "	- $e2eTestFile"
		cp "$e2eTestFile" "$FLAP_DIR/home/e2e/tests/services"
	done
done