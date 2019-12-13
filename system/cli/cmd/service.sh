#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
		echo "service | [summarize, help] | Create a service's file hierarchy."
		;;
	help)
		echo "
		ip | Get ip address.
		Commands:
			internal | | Show the internal ip.
			external | | Show the external ip." | column -t -s "|"
		;;
	*)
		NAME=$CMD
		DIR=$FLAP_DIR/$NAME

		if [ -d $DIR ]
		then
			echo "* [service] Updating $NAME."
		else
			echo "* [service] Creating $NAME."
			mkdir -p $DIR
		fi

		cd $DIR

		[ ! -f $DIR/README.md ] && echo "### $NAME for FLAP." > $DIR/README.md
		cp $FLAP_DIR/LICENSE $DIR/LICENSE
		[ ! -f $DIR/.gitignore ] && echo "${NAME}.env" > $DIR/.gitignore
		touch $DIR/${NAME}.template.env
		touch $DIR/Dockerfile
		touch $DIR/docker-entrypoint.sh
		chmod +x $DIR/docker-entrypoint.sh
		touch $DIR/docker-compose.yml
		touch $DIR/nginx.conf

		mkdir -p $DIR/scripts

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

		mkdir -p $DIR/scripts/migrations
		[ ! -f $DIR/scripts/migrations/base_migration.txt ] && echo "0" > $DIR/scripts/migrations/base_migration.txt

		mkdir -p $DIR/config
		touch $DIR/config/lemon.jq
		;;
esac
