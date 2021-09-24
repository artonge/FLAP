#!/bin/bash

set -eu

exit_code=0

if [ "${BACKUP_TOOL:-}" == "" ]
then
	echo "- No backup tool configured."
	exit 1
fi

exit "$exit_code"
