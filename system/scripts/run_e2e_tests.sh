#!/bin/bash

set -euo pipefail

if [ "${CI:-}" == "true" ]
then
	eval "$(docker exec flap flapctl config show)"
else
	eval "$(sudo -E flapctl config show)"
fi

if [ "${FLAP_DEBUG:-}" == "true" ]
then
	debug_args=(--verbose --debug)
fi

if [ "${CI:-}" == "true" ]
then
	ci_args=(--profile=chrome-ci --reporter mocha-junit-reporter)
fi

service="${1:-}"
if [ "$service" != "" ]
then
	service_args=(--fgrep "$service")
fi

npm install --silent codeceptjs typescript ts-node puppeteer mocha-junit-reporter

rm -f "$FLAP_DIR/system/e2e/tests/services/*"

echo "Copying e2e test files."
for service in $FLAP_SERVICES
do
	if [ "$service" == "system" ]
	then
		continue
	fi

	for e2eTestFile in "$FLAP_DIR/$service"/e2e/*.ts
	do
		[[ -e "$e2eTestFile" ]] || break

		echo "	- $(basename "$e2eTestFile")"
		cp "$e2eTestFile" "$FLAP_DIR/system/e2e/tests/services"
	done
done

echo "Running e2e..."
npx codeceptjs run "${debug_args[@]}" "${ci_args[@]}" "${service_args[@]}"
