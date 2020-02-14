#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	post_install|post_update|post_domain_update|health_check|clean)
		echo "* [hooks] Running $CMD hooks."

		# Go to FLAP_DIR to allow docker-compose cmds.
		cd "$FLAP_DIR"

		mapfile -t SERVICES < <(ls --directory "$FLAP_DIR"/*/)

		if [ "$#" != "1" ]
		then
			SERVICES=("$@")
			SERVICES=("${SERVICES[@]:1}")
		fi

		# Run the targeted hook for each service.
		for service in "${SERVICES[@]}"
		do
			if [ ! -d "$service" ]
			then
				continue
			fi

			service=$(basename "$service")

			# Check if the hook exists
			if [ -f "$FLAP_DIR/$service/scripts/hooks/$CMD.sh" ]
			then
				echo "* [hooks:$CMD] Running for $service."

				"$FLAP_DIR/$service/scripts/hooks/$CMD.sh"
			fi
		done
		;;
	summarize)
		echo "hooks | [post_install, post_update, post_domain_update, health_check, clean] [<service-name>, ...] | Run hooks."
		;;
	help|*)
		echo "
$(hooks summarize)
Commands:
	post_install | [<service-name>, ...] | Run the post_install hook for all or some services.
	post_update | [<service-name>, ...] | Run the post_update hook for all or some services.
	post_domain_update | [<service-name>, ...] | Run the post_domain_update hook for all or some services.
	health_check | [<service-name>, ...] | Run the health_check hook for all or some services.
	clean | [<service-name>, ...] | Run the clean hook for all or some services." | column -t -s "|"
esac
