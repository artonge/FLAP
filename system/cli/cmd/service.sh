#!/bin/bash

set -eu

CMD=${1:-}
NAME=${2:-}
DIR=$FLAP_DIR/$NAME

case $CMD in
	all)
		SUB_CMD=${2:-}
		for service in $(ls --directory $FLAP_DIR/*/)
		do
			flapctl service $SUB_CMD $(basename $service)
		done
		;;
	default)
		if [ -d $DIR ]
		then
			echo "* [service] Updating $NAME."
		else
			echo "* [service] Creating $NAME."
			mkdir -p $DIR
		fi

		cd $DIR

		[ ! -f $DIR/README.md ] && echo "### $NAME for FLAP." > $DIR/README.md

		touch $DIR/.gitignore

		touch $DIR/docker-compose.yml
		touch $DIR/docker-compose.override.yml

		mkdir -p $DIR/scripts

		mkdir -p $DIR/scripts/migrations
		[ ! -f $DIR/scripts/migrations/base_migration.txt ] && echo "0" > $DIR/scripts/migrations/base_migration.txt

		mkdir -p $DIR/scripts/hooks
		touch $DIR/scripts/hooks/clean.sh
		chmod +x $DIR/scripts/hooks/clean.sh
		touch $DIR/scripts/hooks/health_check.sh
		chmod +x $DIR/scripts/hooks/health_check.sh
		touch $DIR/scripts/hooks/post_domain_update.sh
		chmod +x $DIR/scripts/hooks/post_domain_update.sh
		touch $DIR/scripts/hooks/post_install.sh
		chmod +x $DIR/scripts/hooks/post_install.sh
		touch $DIR/scripts/hooks/post_update.sh
		chmod +x $DIR/scripts/hooks/post_update.sh
		;;
	docker)
		flapctl service default $NAME

		touch $DIR/Dockerfile
		touch $DIR/docker-entrypoint.sh
		chmod +x $DIR/docker-entrypoint.sh
		touch $DIR/${NAME}.template.env
		;;
	submodule)
		flapctl service default $NAME

		cp $FLAP_DIR/LICENSE $DIR/LICENSE
		;;
	summarize)
		echo "service | [default, submodule, summarize, help] | Create or update a service's file hierarchy."
		;;
	help|*)
		echo "
$(flapctl service summarize)
Commands:
	default | | Create README.md, scripts, docker-compose.yml and .gitignore.
	docker | | Create Dockerfile, docker-entrypoint.sh and .env.
	submodule | | Init the git repository and create LICENSE." | column -t -s "|"
		;;
esac
