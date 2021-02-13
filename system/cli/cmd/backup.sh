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

		cp "$FLAP_DATA"/system/flapctl.env /tmp/flapctl.env
		rm -rf "$FLAP_DATA"/*
		mkdir -p "$FLAP_DATA"/system
		cp /tmp/flapctl.env "$FLAP_DATA"/system/flapctl.env

		echo "* [backup] Restoring FLAP_DATA."
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" "$@"

		# If git head is a tag, checkout current_tag.
		cd "$FLAP_DIR"
		if [ "$(git rev-parse --abbrev-ref HEAD)" == "HEAD" ]
		then
			current_tag=$(cat "$FLAP_DATA"/system/current_tag.txt)
			git checkout "$current_tag"
		fi

		flapctl config generate

		flapctl hooks post_restore

		flapctl start
	;;
	list)
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" list
	;;
	summarize)
		echo "backup | [restore, list] | Backup and restore FLAP's data."
	;;
	help|*)
		echo "
$(flapctl backup summarize)
Commands:
	'' | | Run pre_backup hook and backup FLAP_DATA using borg or restic.
	restore | | Restore FLAP_DATA using borg or restic and run post_restore hook.
	list | | List available snapshots." | column -t -s "|"
	;;
esac
