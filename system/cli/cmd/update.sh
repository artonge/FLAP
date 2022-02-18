#!/bin/bash

set -euo pipefail

# This file handles the update logic of a FLAP box.
# WARNING: If you change this file, the following update will not use the updated version. So make sure you don't break self calls.

CMD=${1:-}

EXIT_CODE=0

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

case $CMD in
	summarize)
		echo "update | [<branch_name>, help] | Handle update logic for FLAP."
		;;
	help)
		echo "
$(flapctl update summarize)
Commands:
	update | [branch_name] | Update FLAP to the most recent version. Specify <branch_name> if you want to update to a given branch." | column -t -s "|"
		;;
	images)
		services_to_restart=()

		for service in $FLAP_SERVICES
		do
			mapfile -t sub_services < <(yq -r '.services | keys[]' "$FLAP_DIR/$service/docker-compose.yml");

			for sub_service in "${sub_services[@]}"
			do
				# shellcheck disable=SC2016
				image=$(yq -r --arg sub_service "$sub_service" '.services[$sub_service].image' "$FLAP_DIR/$service/docker-compose.yml")

				image_digest=$(docker image inspect --format '{{ index .RepoDigests 0 }}' "$image")
				docker-compose pull "${args[@]}" "$sub_service"
				new_image_digest=$(docker image inspect --format '{{ index .RepoDigests 0 }}' "$image")

				if [ "$image_digest" != "$new_image_digest" ]
				then
					services_to_restart+=("$sub_service")
				fi
			done
		done

		if [ "${services_to_restart[*]}" != "" ]
		then
			docker-compose restart "${services_to_restart[@]}"
		fi
		;;
	""|*)
		# Go to FLAP_DIR for git cmds.
		cd "$FLAP_DIR"

		git fetch "${args[@]}" --force --tags --prune --prune-tags --recurse-submodules

		current_tag=$(flapctl version)
		next_tag=$(git tag --sort version:refname | { grep -A 1 "$current_tag" || true; } | { grep -v "$current_tag" || true; })
		arg_tag=${1:-}
		target=${arg_tag:-$next_tag}

		# Stop update when we are on a branch unless a target is provided.
		if [ "$(git rev-parse --abbrev-ref HEAD)" != "HEAD" ] && [ "$target" = "" ]
		then
			exit 0
		fi

		# Abort update if there is no target.
		if [ "${target:-0.0.0}" == '0.0.0' ]
		then
			exit 0
		fi

		echo "* [update] Backing up."
		flapctl backup

		{
			echo "* [update] Updating code from $current_tag to $target." &&
			git checkout "${args[@]}" --force --recurse-submodules "$target" &&
			# Hard clean the repo.
			git add . &&
			git reset "${args[@]}" --hard &&
			# Pull changes if we are on a branch.
			if [ "$(git rev-parse --abbrev-ref HEAD)" != "HEAD" ]
			then
				git pull "${args[@]}" --force --recurse-submodules
			fi &&

			# Update docker-compose.yml to pull new images.
			flapctl config generate_templates &&
			flapctl hooks generate_config system &&
			echo '* [update] Pulling new docker images.' &&
			docker-compose pull "${args[@]}"
		} || {
			# When either the git update or the docker pull fails, it is safer to go back to the previous tag.
			# This will prevent from:
			# - starting without the docker images,
			# - running migrations on an unknown state.
			echo '* [update] ERROR - Fail to update, going back to previous commit.'
			git checkout "${args[@]}" --force --recurse-submodules "$current_tag"
			exit 1
		}

		{
			echo '* [update] Restarting containers.' &&
			flapctl restart &&

			flapctl hooks post_update &&

			echo '* [update] Cleaning docker objects.' &&
			flapctl clean docker -y
		} || {
			echo '* [update] ERROR - Fail to restart containers.'
			EXIT_CODE=1
		}

		flapctl ports setup
		flapctl setup firewall
		flapctl setup cron

		# Get new current info.
		current_branch=$(git rev-parse --abbrev-ref HEAD)
		current_tag=$(git describe --tags --abbrev=0)
		current_commit="$(git rev-parse HEAD)"
		current=$current_branch

		# If we are not on a branch, use current_tag.
		if [ "$current_branch" == "HEAD" ]
		then
			current="$current_tag"
			tag_head="$(git show-ref --tags --hash "$current_tag")"

			# If we are not on a tag, use current_commit.
			if [ "$current_commit" != "$tag_head" ]
			then
				current="$current_commit"
			fi
		fi

		if [ "$current" != "$target" ]
		then
			echo "* [update] ERROR - FLAP is on $current instead of $target."
			exit 1
		fi

		flapctl version > "$FLAP_DATA/system/version.txt"

		# Recursively continue to newer updates.
		flapctl update
		;;
esac

exit "$EXIT_CODE"
