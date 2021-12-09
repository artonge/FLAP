#!/bin/bash

set -eu

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

# Restic arguments are passed with environment variables.
# https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables

# Alias restic to reduce its resource usage.
restic() { nice --adjustment 10 ionice --class 2 restic "${args[@]}" "$@"; }

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
		restic backup "$FLAP_DATA" --tag "$FLAP_VERSION"
		restic forget --prune --keep-hourly 2 --keep-daily 7 --keep-weekly 5 --keep-monthly 12
		restic rebuild-index
		if [ "${FLAG_NO_BACKUP_CHECK:-}" != "true" ]
		then
			restic check
		fi
	;;
	restore)
		snapshot_id=${2:-"$(restic snapshots --latest 1 --json --path "$FLAP_DATA" | jq --raw-output '.[-1].id')"}
		restic restore --target / "$snapshot_id"
	;;
	last)
		date --utc --date "$(restic snapshots --latest 1 --json --path "$FLAP_DATA" | jq --raw-output '.[-1].time')" +"%Y-%m-%d"
	;;
	list)
		restic snapshots
	;;
esac
