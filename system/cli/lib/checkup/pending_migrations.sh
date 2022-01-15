#!/bin/bash

set -euo pipefail

exit_code=0

# pending_migrations=$(flapctl migrate status)
mapfile -t pending_migrations < <(flapctl migrate status)

if [[ "${#pending_migrations[@]}" != "0" ]]
then
	echo "- You have pending migration."

	for pending_migration in "${pending_migrations[@]}"
	do
		echo "	- $pending_migration"
	done
	exit_code=1
fi

exit $exit_code