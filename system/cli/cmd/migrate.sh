#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
		echo "migrate | [<service_name> ..., status, help] | Run services migrations."
	;;
	help)
		echo "
$(flapctl migrate summarize)
Commands:
	migrate | [<service_name> ...] | Run migrations for the specified services, default to all services.
	migrate | status | List pending migrations." | column -t -s "|"
	;;
	status)
		for service in $FLAP_SERVICES
		do
			current_migration=$(cat "$FLAP_DATA/$service/current_migration.txt")
			needed_migrations=()

			while [ -f "$FLAP_DIR/$service/scripts/migrations/$((current_migration+1)).sh" ]
			do
				needed_migrations+=($((current_migration+1)))
				current_migration=$((current_migration+1))
			done

			if [ ${#needed_migrations[@]} != 0 ]
			then
				echo "$service: [${needed_migrations[*]}]"
			fi
		done
	;;
	""|*)
		# Go to FLAP_DIR to allow docker-compose cmds.
		cd "$FLAP_DIR"

		# Get services list from args.
		services=${*:1}
		# Default services list to FLAP_SERVICES.
		services=${services:-$FLAP_SERVICES}

		echo "* [migrate] Running migrations for $services."
		# Run the hook for each services.
		for service in $services
		do
			# Get the base migration for the service.
			# The current migration is the last migration that was run.
			current_migration=$(cat "$FLAP_DATA/$service/current_migration.txt")

			# Run migration scripts as long as there is some to run.
			while [ -f "$FLAP_DIR/$service/scripts/migrations/$((current_migration+1)).sh" ]
			do
				echo "* [migrate] Migrating $service from $current_migration to $((current_migration+1))."

				{
					"$FLAP_DIR/$service/scripts/migrations/$((current_migration+1)).sh" &&
					current_migration=$((current_migration+1)) &&
					echo "* [migrate] Migration $current_migration done." &&
					echo "$current_migration" > "$FLAP_DATA/$service/current_migration.txt"
				} || {
					echo "* [migrate] ERROR - Fail to run migrations for $service."
					break
				}
			done
		done
	;;
esac
