#!/bin/bash

set -eu

# Run hooks located in service's 'scripts/hooks' directory.
# This hooks are called during FLAP lifecycle.
# During the hooks execution, we also call 'sub-hooks'.
# Those sub-hooks allow us to make some setup, or to prevent the execution of hooks.
# Examples:
# 	- The pre and post_install hooks are run only if $FLAP_DATA/$service/installed.txt do not exists.
# 	- The init_db hooks expect to have the database running.

cmd=${1:-}

pre_run_has_run=false

# SUB-HOOKS
function pre_run_all {
	local hook=$1

	if [ "$pre_run_has_run" == "true" ]
	then
		return 0
	fi

	pre_run_has_run=true

	case $hook in
		init_db)
			echo "* [hooks] Starting PostgreSQL and MariaDB for init_db hook."
			flapctl start postgres mariadb
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
		pre_install|post_install|init_db)
			if [ -f "$FLAP_DATA/$service/installed.txt" ]
			then
				return 1
			fi
		;;
	esac
}

function post_run_all {
	local hook=$1
	local services=("$@")
	local services=("${services[@]:1}")

	# Services in $FLAP_SERVICES without an install.txt file are not yet installed but will be after post_install.
	pending_install_services=()
	for service in $FLAP_SERVICES
	do
		if [ -f "$FLAP_DATA/$service/installed.txt" ]
		then
			continue
		fi
		pending_install_services+=("$service")
	done

	# Post-hooks executed even if no hook has been executed.
	case $hook in
		pre_install)
			if [ "${pending_install_services[*]}" == "" ]
			then
				exit 0
			fi

			echo "* [hooks] Generating TLS certificates for new services."
			flapctl tls generate
		;;
		post_install)
			if [ "${pending_install_services[*]}" == "" ]
			then
				exit 0
			fi

			echo "* [hooks] Restarting lemon and nginx after post_install."
			flapctl restart lemon nginx

			echo "* [hooks] Finish services install."
			flapctl ports setup
			flapctl setup firewall
			flapctl setup cron

			for service in "${pending_install_services[@]}"
			do
				echo "* [hooks] Marking $service as installed."
				touch "$FLAP_DATA/$service/installed.txt"
			done

			if [ "$PRIMARY_DOMAIN_NAME" != "" ]
			then
				echo "* [hooks] Running post_domain_update for ${pending_install_services[*]} after post_install."
				flapctl hooks post_domain_update "${pending_install_services[@]}"
			fi
		;;
	esac

	# Return if no hooks has been executed.
	if [ "$pre_run_has_run" == "false" ]
	then
		return 0
	fi

	# Post-hooks executed only if a least one hook has been executed.
	case $hook in
		init_db)
			echo "* [hooks] Shutting PostgreSQL and MariaDB down after init_db hook."
			flapctl stop postgres mariadb
		;;
		pre_install)
			echo "* [hooks] Regenerating config after pre_install."
			flapctl config generate
		;;
		post_domain_update)
			echo "* [hooks] Restarting lemon after post_domain_update."
			flapctl restart lemon
		;;
	esac
}


case $cmd in
	init_db|pre_install|post_install|generate_config|wait_ready|post_update|post_domain_update|health_check|clean|pre_backup|post_restore)
		hook=$cmd
		exit_code=0
		hooks_ran=()

		# Go to FLAP_DIR to allow docker-compose cmds.
		cd "$FLAP_DIR"

		# Get services list from args.
		services_list=${*:2}
		# Default services list to FLAP_SERVICES.
		services_list=${services_list:-$FLAP_SERVICES}

		for service in $services_list
		do
			service=$(basename "$service")

			if ! should_run "$hook" "$service"
			then
				continue
			fi

			# Run pre_run_all here so we do not run it if no hooks need to be run.
			pre_run_all "$hook" "$services_list"

			echo "* [hooks] Running $hook hook for $service."
			if "$FLAP_DIR/$service/scripts/hooks/$hook.sh"
			then
				hooks_ran+=("$service")
			else
				echo "* [hook] Error: Hook $hook failed for $service"
				exit_code=1
			fi
		done

		post_run_all "$hook" "${hooks_ran[@]}"

		exit "$exit_code"
	;;
	summarize)
		echo "hooks | [init_db, pre_install, post_install, ...] [<service-name> ...] | Run hooks for the specified services, default to all services.."
	;;
	help|*)
		echo "
$(flapctl hooks summarize)
Commands:
	init_db | [<service-name> ...] | Run the init_db hook for all or some services.
	pre_install | [<service-name> ...] | Run the pre_install hook for all or some services.
	post_install | [<service-name> ...] | Run the post_install hook for all or some services.
	generate_config | [<service-name> ...] | Run the generate_config hook for all or some services.
	wait_ready | [<service-name> ...] | Wait for the service to be up and ready.
	post_update | [<service-name> ...] | Run the post_update hook for all or some services.
	post_domain_update | [<service-name> ...] | Run the post_domain_update hook for all or some services.
	health_check | [<service-name> ...] | Run the health_check hook for all or some services.
	pre_backup | [<service-name> ...] | Run the pre_backup hook for all or some services.
	post_restore | [<service-name> ...] | Run the post_restore hook for all or some services.
	clean | [<service-name> ...] | Run the clean hook for all or some services." | column -t -s "|"
	;;
esac
