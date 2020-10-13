#!/bin/bash

set -eu

# Exit early if borg does not have the correct environment variables.
if [ "${BORG_REPO:-}" == "" ] || [ "${BORG_PASSPHRASE:-}" == "" ]
then
	exit 1
fi

if ! borg info > /dev/null
then
	borg init --encryption repokey
fi

CMD=${1:-}
case $CMD in
	backup)
		borg create --compression lz4 ::'{hostname}-{now}'-"$FLAP_VERSION" "$FLAP_DATA"
		borg prune --keep-hourly 2 --keep-daily 7 --keep-weekly 5 --keep-monthly 12
		if [ "${FLAG_NO_BACKUP_CHECK:-}" != "true" ]
		then
			borg check
		fi
	;;
	restore)
		archive=$(borg list --json | jq --raw-output '.archives[.archives | length - 1].archive')
		# Currently, extract always writes into the current working directory (".")
		# Cd into FLAP_DATA's parent.
		cd "$FLAP_DATA"/..
		borg extract --progress ::"$archive"
	;;
esac
