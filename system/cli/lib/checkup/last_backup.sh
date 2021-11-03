#!/bin/bash

set -eu

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

exit "$exit_code"
