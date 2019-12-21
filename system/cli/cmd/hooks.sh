#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	post_install|post_update|post_domain_update|health_check|clean)
		echo "* [hooks] Running $CMD hook:"

		SERVICES=($@)
		SERVICES=${SERVICES[@]:1}
		SERVICES=${SERVICES:-$(ls --directory $FLAP_DIR/*/)}

		# Go to FLAP_DIR to allow docker-compose cmds.
		cd $FLAP_DIR

		# Run the targeted hook for each service.
		for service in $SERVICES
		do
			service=$(basename $service)

			# Check if the hook exists
			if [ -f $FLAP_DIR/$service/scripts/hooks/$CMD.sh ]
			then
				echo "  - $service"
				$FLAP_DIR/$service/scripts/hooks/$CMD.sh
			fi
		done
		;;
	summarize)
		echo "hooks | [post_install, post_update, post_domain_update, health_check, clean] [<service-name>, ...] | Run hooks."
		;;
	help|*)
		echo "
hooks | Run hooks.
Commands:
	post_install | [<service-name>, ...] | Run the post_install hook for all or some services.
	post_update | [<service-name>, ...] | Run the post_update hook for all or some services.
	post_domain_update | [<service-name>, ...] | Run the post_domain_update hook for all or some services.
	health_check | [<service-name>, ...] | Run the health_check hook for all or some services.
	clean | [<service-name>, ...] | Run the clean hook for all or some services." | column -t -s "|"
esac
