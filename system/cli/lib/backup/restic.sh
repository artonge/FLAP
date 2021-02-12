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
		restic backup --quiet "$FLAP_DATA" --tag "$FLAP_VERSION"
		restic forget --quiet --prune --keep-hourly 2 --keep-daily 7 --keep-weekly 5 --keep-monthly 12
		restic rebuild-index --quiet
		if [ "${FLAG_NO_BACKUP_CHECK:-}" != "true" ]
		then
			restic check --quiet
		fi
	;;
	restore)
		snapshot_id=${2:-"$(restic snapshots --last --json --path "$FLAP_DATA" | jq --raw-output '.[-1].id')"}
		restic restore --quiet --target / "$snapshot_id"
	;;
	list)
		restic snapshots
	;;
esac
