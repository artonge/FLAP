#!/bin/bash

set -euo pipefail

exit_code=0

if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
then
	exit 0
fi

if [ "${BACKUP_TOOL:-}" == "" ]
then
	echo "- No backup tool configured."
	exit_code=1
fi

last_backup=$(flapctl backup last)
last_week=$(date --utc +"%Y-%m-%d" --date "-1week")

if [[ $last_backup < $last_week ]]
then
	echo "- The last backup is older than a week ago."
	exit_code=1
fi

exit "$exit_code"
