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
	images)
		docker-compose --no-ansi pull
		flapctl restart
		;;
	""|*)
		# Go to FLAP_DIR for git cmds.
		cd "$FLAP_DIR"

		git fetch --force --tags --prune --prune-tags --recurse-submodules &> /dev/null

		current_tag=$(git describe --tags --abbrev=0)
		next_tag=$(git tag --sort version:refname | grep -A 1 "$current_tag" | grep -v "$current_tag" | cat)
		arg_tag=${1:-}
		target=${arg_tag:-$next_tag}

		# Abort update if there is no target.
		if [ "${target:-0.0.0}" == '0.0.0' ]
		then
			exit 0
		fi

		echo "* [update] Backing up." &&
		flapctl backup

		{
			echo "* [update] Updating code from $current_tag to $target." &&
			git checkout --force --recurse-submodules "$target" &&
			# Pull changes if we are on a branch.
			if [ "$(git rev-parse --abbrev-ref HEAD)" != "HEAD" ]
			then
				git pull --force --recurse-submodules
			fi

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
			git checkout --force --recurse-submodules "$current_tag"
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

		# Check new current HEAD.
		current_head=$(git rev-parse --abbrev-ref HEAD)
		if [ "$current_head" == "HEAD" ]
		then
			current_head=$(git describe --tags --abbrev=0)
		fi

		if [ "$current_head" != "$target" ]
		then
			echo "* [update] ERROR - FLAP is on $current_head instead of $target."
			exit 1
		fi

		# Recursivly continue to newer updates.
		flapctl update
		;;
esac

exit $EXIT_CODE
