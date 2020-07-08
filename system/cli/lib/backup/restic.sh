#!/bin/bash

set -eu

# Restic arguments are passed with environment variables.
# https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables

# Alias restic to reduce its ressource usage.
restic() { nice --adjustment 10 ionice --class 2 restic "$@"; }

# Exit early if restic does not have the correct environment variables.
if [ "${RESTIC_REPOSITORY:-}" == "" ] || [ "${RESTIC_PASSWORD:-}" == "" ]
then
	exit 1
fi

if ! restic snapshots > /dev/null
then
	restic init
fi

CMD=${1:-}
case $CMD in
	backup)
		restic backup --quiet "$FLAP_DATA"
		restic forget --quiet --prune --keep-hourly 2 --keep-daily 7 --keep-weekly 5 --keep-monthly 12
		restic rebuild-index --quiet
		restic check --quiet
	;;
	restore)
		snapshot_id=$(restic snapshots --last --json | jq --raw-output '.[0].id')
		restic restore --quiet --target / "$snapshot_id"
	;;
esac
