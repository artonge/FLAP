#!/bin/bash

set -euo pipefail

CMD=${1:-}

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

if [ "${BACKUP_TOOL:-}" == "" ]
then
	exit 0
fi

case $CMD in
	"")
		flapctl version > "$FLAP_DATA/system/version.txt"

		if [ "${FLAP_DEBUG:-}" == "true" ]
		then
			output=/dev/stdout
		else
			output=/dev/null
		fi

		flapctl hooks pre_backup > $output

		debug "* [backup] Creating backup with $BACKUP_TOOL."
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" backup
	;;
	restore)
		flapctl stop

		backup_filename="/tmp/flapctl.env.$(date --iso).bak"
		cp "$FLAP_DATA"/system/flapctl.env "$backup_filename"
		rm -rf "${FLAP_DATA:?}"/*
		mkdir -p "$FLAP_DATA"/system
		cp "$backup_filename" "$FLAP_DATA"/system/flapctl.env

		echo "* [backup] Restoring FLAP_DATA with $BACKUP_TOOL."
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" "$@"

		# If git head is a tag, checkout version.
		cd "$FLAP_DIR"
		if [ "$(git rev-parse --abbrev-ref HEAD)" == "HEAD" ]
		then
			version=$(cat "$FLAP_DATA"/system/version.txt)
			echo "* [backup] Checking out $version."
			git checkout "${args[@]}" "$version"
		fi

		echo "* [backup] Starting reanimation with the following flapctl.env."
		cat "$FLAP_DATA/system/flapctl.env"
		flapctl config show

		flapctl config generate
		flapctl hooks post_restore
		flapctl start
		flapctl ports setup
		flapctl setup firewall
		flapctl setup cron
	;;
	list)
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" list
	;;
	last)
		"$FLAP_LIBS/backup/$BACKUP_TOOL.sh" last
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
