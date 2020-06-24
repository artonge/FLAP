#!/bin/bash

set -eu

CMD=${1:-}

if [ "${BACKUP_TOOL:-}" == "" ]
then
	exit 0
fi

case $CMD in
	"")
		flapctl hooks pre_backup > /dev/null

		# Save current_tag.txt.
		cd "$FLAP_DIR"
		current_tag=$(git describe --tags --abbrev=0)
		echo "$current_tag" > "$FLAP_DATA/system/current_tag.txt"

		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" backup
	;;
	restore)
		flapctl stop

		# If git head is a tag, checkout current_tag.
		if [ "$(git rev-parse --abbrev-ref HEAD)" == "HEAD" ]
		then
			"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" extract_current_tag
			current_tag=$(cat "$FLAP_DATA"/system/current_tag.txt)
			cd "$FLAP_DIR"
			git checkout "$current_tag"
		fi

		echo "* [backup] Restoring FLAP_DATA."
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" restore

		flapctl config generate

		flapctl hooks post_restore

		flapctl start
	;;
	summarize)
		echo "backup | | Backup and restore FLAP's data."
	;;
	help|*)
		echo "
$(flapctl backup summarize)
Commands:
	'' | | Run pre_backup hook and backup FLAP_DATA using borg or restic.
	restore | | Restore FLAP_DATA usign borg or restic and run post_restore hook." | column -t -s "|"
	;;
esac
