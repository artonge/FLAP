#!/bin/bash

set -eu

# Run hooks located in service's 'scripts/hooks' directory.
# This hooks are called during FLAP lifecycle.
# During the hooks execution, we also call 'sub-hooks'.
# Those sub-hooks allow us to make some setup, or to prevent the execution of hooks.
# Examples:
# 	- The pre and post_install hooks are run only if $FLAP_DATA/$service/installed.txt do not exists.
# 	- The init_db hooks supose to have the database running.

cmd=${1:-}

pre_run_has_run=false

# SUB-HOOKS
function pre_run_all {
	local hook=$1

	if [ $pre_run_has_run == "true" ]
	then
		return 0
	fi

	pre_run_has_run=true

	echo "* [hooks] Running $hook hooks."

	case $hook in
		init_db)
			echo "* [hooks] Starting PostgreSQL for init_db hook."
			docker-compose --no-ansi up --detach postgres
		;;
	esac
}

function should_run {
	local hook=$1
	local service=$2

	if [ ! -f "$FLAP_DIR/$service/scripts/hooks/$hook.sh" ]
	then
		return 1
	fi

	if [ -f "$FLAP_DIR/$service/scripts/hooks/should_install.sh" ] && ! "$FLAP_DIR/$service/scripts/hooks/should_install.sh"
	then
		return 1
	fi

	case $hook in
		generate_config)
		;;
		pre_install|post_install|init_db)
			if [ -f "$FLAP_DATA/$service/installed.txt" ]
			then
				return 1
			fi
		;;
	esac
}

function post_run {
	local hook=$1
	local service=$2

	case $hook in
		post_install)
			echo "* [hooks] Marking $service as installed."
			touch "$FLAP_DATA/$service/installed.txt"
		;;
	esac
}

function post_run_all {
	local hook=$1
	local services=("$@")
	local services=("${services[@]:1}")

	# Only run post_run_all if a hook has been run.
	if [ $pre_run_has_run == "false" ]
	then
		return 0
	fi

	case $hook in
		init_db)
			echo "* [hooks] Shutting PostgreSQL down for init_db hook."
			docker-compose --no-ansi down
		;;
		post_install)
			# If a primary domain name is set,
			# we need to run post_domain_update hooks for freshly installed services.
			if [ "$PRIMARY_DOMAIN_NAME" != "" ]
			then
				flapctl hooks post_domain_update "${services[@]}"
			fi
		;;
		post_domain_update)
			echo "* [hooks] Restarting services after post_domain_update hook."
			flapctl restart
		;;
	esac
}


case $cmd in
	init_db|pre_install|post_install|generate_config|post_update|post_domain_update|health_check|clean)
		hook=$cmd
		exit_code=0
		hooks_ran=()

		# Go to FLAP_DIR to allow docker-compose cmds.
		cd "$FLAP_DIR"

		# Get services list.
		mapfile -t services < <(ls --directory "$FLAP_DIR"/*/)

		#                 1         2     ...
		# flapctl hooks <hook> [<service> ...]
		# More than 1 arg mean a list of services.
		if [ "$#" != "1" ]
		then
			services=("$@")
			services=("${services[@]:1}")
		fi

		# Run the hook for each service.
		for service in "${services[@]}"
		do
			service=$(basename "$service")

			if ! should_run "$hook" "$service"
			then
				continue
			fi

			# Run pre_run_all here so we do not run it if no hooks need to be run.
			pre_run_all "$hook" "${services[@]}"

			echo "* [hooks] Running $hook hook for $service."
			"$FLAP_DIR/$service/scripts/hooks/$hook.sh"

			hook_exit_code=${PIPESTATUS[0]}
			# Catch error code
			if [ "$hook_exit_code" != "0" ]
			then
				exit_code=1
			fi

			# Do not run post_run sub-hook if the hook failed.
			if [ "$hook_exit_code" == "0" ]
			then
				hooks_ran+=("$service")
				post_run "$hook" "$service"
			fi
		done

		post_run_all "$hook" "${hooks_ran[@]}"

		exit "$exit_code"
	;;
	summarize)
		echo "hooks | [post_install, pre_update, post_update, post_domain_update, health_check, clean] [<service-name>, ...] | Run hooks."
	;;
	help|*)
		echo "
$(hooks summarize)
Commands:
	init_db | [<service-name>, ...] | Run the init_db hook for all or some services.
	pre_install | [<service-name>, ...] | Run the pre_install hook for all or some services.
	post_install | [<service-name>, ...] | Run the post_install hook for all or some services.
	generate_config | [<service-name>, ...] | Run the generate_config hook for all or some services.
	post_update | [<service-name>, ...] | Run the post_update hook for all or some services.
	post_domain_update | [<service-name>, ...] | Run the post_domain_update hook for all or some services.
	health_check | [<service-name>, ...] | Run the health_check hook for all or some services.
	clean | [<service-name>, ...] | Run the clean hook for all or some services." | column -t -s "|"
	;;
esac
