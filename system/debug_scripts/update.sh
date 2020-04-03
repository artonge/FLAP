#!/bin/bash

# ./update.sh v1-0-13 v1.0.14

set -eux

TAG=$1
TO=$2

docker run \
	--detach \
	--name flap_update \
	\
	--env CI=true \
	--env LOG_DRIVER=json-file \
	\
	--volume /var/run/docker.sock:/var/run/docker.sock \
	\
	--volume /flap_dir:/flap_dir \
	--volume /flap_data:/flap_data \
	\
	--env FLAP_DIR=/flap_dir \
	--env FLAP_DATA=/flap_data \
	\
	"registry.gitlab.com/flap-box/flap/$TAG" \
	\
	/bin/sh -c "while true; do sleep 1000; done"


docker exec flap_update flapctl stop

docker exec flap_update rm -rf /flap_data/*
docker exec flap_update rm -rf /flap_dir/*

docker exec flap_update cp -rT /opt/flap /flap_dir
docker exec flap_update ln -sf /flap_dir/system/cli/flapctl.sh /bin/flapctl

docker exec flap_update flapctl start
docker exec flap_update flapctl tls generate_localhost
docker exec flap_update flapctl restart
docker exec flap_update flapctl hooks post_domain_update

docker exec flap_update flapctl update "$TO"
