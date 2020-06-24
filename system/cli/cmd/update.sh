#!/bin/bash

set -eu

# This file handles the update logic of a FLAP box.
# WARNING: If you change this file, the following update will not use the updated version. So make sure you don't break self calls.

CMD=${1:-}

EXIT_CODE=0

case $CMD in
	summarize)
		echo "update | [<branch_name>, help] | Handle update logique for FLAP."
		;;
	help)
		echo "
$(flapctl update summarize)
Commands:
	update | [branch_name] | Update FLAP to the most recent version. Specify <branch_name> if you want to update to a given branch." | column -t -s "|"
		;;
	""|*)
		# Go to FLAP_DIR for git cmds.
		cd "$FLAP_DIR"

		git fetch --tags --prune > /dev/null

		CURRENT_TAG=$(git describe --tags --abbrev=0)
		NEXT_TAG=$(git tag --sort version:refname | grep -A 1 "$CURRENT_TAG" | grep -v "$CURRENT_TAG" | cat)
		ARG_TAG=${1:-}
		TARGET_TAG=${ARG_TAG:-$NEXT_TAG}

		# Abort update if there is no TARGET_TAG.
		if [ "${TARGET_TAG:-0.0.0}" == '0.0.0' ]
		then
			exit 0
		fi

		# Don't update if an update is already in progress.
		if [ -f /tmp/updating_flap.lock ]
		then
			echo '* [update] Update already in progress, exiting.'
			exit 0
		fi
		touch /tmp/updating_flap.lock

		echo "* [update] Backing up." &&
		flapctl backup

		{
			echo "* [update] Updating code to $TARGET_TAG." &&
			git checkout "$TARGET_TAG" &&

			# Pull changes if we are on a branch.
			if [ "$(git rev-parse --abbrev-ref HEAD)" != "HEAD" ]
			then
				git pull
			fi

			git submodule update --init &&

			# Update docker-compose.yml to pull new images.
			flapctl config generate_templates &&
			flapctl hooks generate_config system &&
			echo '* [update] Pulling new docker images.' &&
			docker-compose --no-ansi pull
		} || {
			# When either the git update or the docker pull fails, it is safer to go back to the previous tag.
			# This will prevent from:
			# - starting without the docker images,
			# - running migrations on an unknown state.
			echo '* [update] ERROR - Fail to update, going back to previous commit.'
			git submodule foreach "git add ."
			git submodule foreach "git reset --hard"
			git submodule foreach "git clean -Xdf"
			git add .
			git reset --hard
			git clean -Xdf
			git checkout "$CURRENT_TAG"
			git submodule update --init
			rm /tmp/updating_flap.lock
			exit 1
		}

		{
			echo '* [update] Restarting containers.' &&
			flapctl restart &&

			flapctl hooks post_update &&

			echo '* [update] Cleanning docker objects.' &&
			flapctl clean docker -y
		} || {
			echo '* [update] ERROR - Fail to restart containers.'
			EXIT_CODE=1
		}

		flapctl setup cron

		rm /tmp/updating_flap.lock
		;;
esac

exit $EXIT_CODE
