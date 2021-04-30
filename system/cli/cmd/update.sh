#!/bin/bash

set -eu

# This file handles the update logic of a FLAP box.
# WARNING: If you change this file, the following update will not use the updated version. So make sure you don't break self calls.

CMD=${1:-}

EXIT_CODE=0

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
				docker-compose pull --quiet "$sub_service"
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

		git fetch --force --tags --prune --prune-tags --recurse-submodules &> /dev/null

		current_tag=$(flapctl version)
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
			docker-compose pull
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

			echo '* [update] Cleaning docker objects.' &&
			flapctl clean docker -y
		} || {
			echo '* [update] ERROR - Fail to restart containers.'
			EXIT_CODE=1
		}

		flapctl ports setup
		flapctl setup firewall
		flapctl setup cron
			
		# Get new current HEAD.
		current_head=$(git rev-parse --abbrev-ref HEAD)
		is_tag=false
		if [ "$current_head" == "HEAD" ]
		then
			is_tag=true
			current_head=$(git describe --tags --abbrev=0)
		fi

		if [ "$current_head" != "$target" ]
		then
			echo "* [update] ERROR - FLAP is on $current_head instead of $target."
			exit 1
		fi

		echo "$current_head" > "$FLAP_DATA/system/version.txt"

		# Recursively continue to newer updates if current HEAD is a tag.
		if [ "$is_tag" ]
		then
			flapctl update
		fi
		;;
esac

exit "$EXIT_CODE"
