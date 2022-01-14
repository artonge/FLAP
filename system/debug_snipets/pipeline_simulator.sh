#!/bin/bash

set -eu

# Create DinD container.
# Bind our working directories so docker can see them.
# Bind some local docker directories to keep images cache accros restarts.
# Ask docker not to use TLS.
docker run \
	--name docker \
	--detach \
	--rm \
	--publish 80:80 \
	--publish 443:443 \
	--volume /flap_dir:/flap_dir \
	--volume /flap_data:/flap_data \
	--volume /flap_backup:/flap_backup \
	--volume /etc/letsencrypt/live/flap:/etc/letsencrypt/live/flap \
	--volume /var/lib/docker/image:/var/lib/docker/image \
	--volume /var/lib/docker/overlay2:/var/lib/docker/overlay2 \
	--env DOCKER_TLS_CERTDIR="" \
	--privileged \
	docker:dind

FLAP_IP=$(docker inspect docker --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

# Log into a docker client container.
# Bind our working directories so we can bind them with a future child container.
# Link the DinD container so we can work with a fresh docker server like in the pipelines.
docker run \
	--name pipeline \
	--rm \
	-it \
	--env CI=true \
	--volume /flap_dir:/flap_dir \
	--volume /flap_data:/flap_data \
	--volume /flap_backup:/flap_backup \
	--volume /etc/letsencrypt/live/flap:/etc/letsencrypt/live/flap \
	--link docker \
	--add-host="flap.local:$FLAP_IP" \
	--add-host="flap.test:$FLAP_IP" \
	--add-host="auth.flap.test:$FLAP_IP" \
	--add-host="home.flap.test:$FLAP_IP" \
	--add-host="files.flap.test:$FLAP_IP" \
	--add-host="mail.flap.test:$FLAP_IP" \
	--add-host="matrix.flap.test:$FLAP_IP" \
	--add-host="chat.flap.test:$FLAP_IP" \
	--add-host="coturn.flap.test:$FLAP_IP" \
	--add-host="jitsi.flap.test:$FLAP_IP" \
	--add-host="weblate.flap.test:$FLAP_IP" \
	--add-host="analytics.flap.test:$FLAP_IP" \
	--add-host="video.flap.test:$FLAP_IP" \
	--add-host="monitoring.flap.test:$FLAP_IP" \
	--add-host="music.flap.test:$FLAP_IP" \
	--add-host="lists.flap.test:$FLAP_IP" \
	--add-host="office.flap.test:$FLAP_IP" \
	docker:stable \
	sh

# Specify the image we want to debug.
CI_REGISTRY_IMAGE=registry.gitlab.com/flap-box/flap
CI_COMMIT_REF_SLUG=
CI_COMMIT_SHA=v1.22.1

FLAP_IP=$(grep docker /etc/hosts | cut -f1)

# Run the specified FLAP images.
# Pass some flags env var.
# Share the docker container network with this container so it can talk to itself.
#  ==> the network ports are being serve from the DinD container, that can be reach from the docker container but not from this container if we do not share the host network stack.
# Add entry to the /etc/hosts file to resolve flap.local and *.flap.test
# Bind our working directories.
# docker pull $CI_REGISTRY_IMAGE/${CI_COMMIT_REF_SLUG}:${CI_COMMIT_SHA}
docker run \
	--name flap \
	--detach \
	--env LOG_DRIVER=json-file \
	--network host \
	--add-host="flap.local:$FLAP_IP" \
	--add-host="flap.test:$FLAP_IP" \
	--add-host="auth.flap.test:$FLAP_IP" \
	--add-host="home.flap.test:$FLAP_IP" \
	--add-host="files.flap.test:$FLAP_IP" \
	--add-host="mail.flap.test:$FLAP_IP" \
	--add-host="matrix.flap.test:$FLAP_IP" \
	--add-host="chat.flap.test:$FLAP_IP" \
	--add-host="coturn.flap.test:$FLAP_IP" \
	--add-host="jitsi.flap.test:$FLAP_IP" \
	--add-host="weblate.flap.test:$FLAP_IP" \
	--add-host="analytics.flap.test:$FLAP_IP" \
	--add-host="video.flap.test:$FLAP_IP" \
	--add-host="monitoring.flap.test:$FLAP_IP" \
	--add-host="music.flap.test:$FLAP_IP" \
	--add-host="lists.flap.test:$FLAP_IP" \
	--add-host="office.flap.test:$FLAP_IP" \
	--volume /var/run/docker.sock:/var/run/docker.sock \
	--volume /flap_dir:/flap_dir \
	--volume /flap_data:/flap_data \
	--volume /flap_backup:/flap_backup \
	--volume /etc/letsencrypt/live/flap:/etc/letsencrypt/live/flap \
	--env FLAP_DIR=/flap_dir \
	--env FLAP_DATA=/flap_data \
	--env FLAP_DEBUG="${FLAP_DEBUG:-false}" \
	--env ENABLE_NEXTCLOUD="${ENABLE_NEXTCLOUD:-false}" \
	--env ENABLE_COLLABORA="${ENABLE_COLLABORA:-false}" \
	--env ENABLE_SOGO="${ENABLE_SOGO:-false}" \
	--env ENABLE_MATRIX="${ENABLE_MATRIX:-false}" \
	--env ENABLE_JITSI="${ENABLE_JITSI:-false}" \
	--env ENABLE_PEERTUBE="${ENABLE_PEERTUBE:-false}" \
	--env ENABLE_FUNKWHALE="${ENABLE_FUNKWHALE:-false}" \
	--env ENABLE_MAILMAN="${ENABLE_MAILMAN:-false}" \
	--env ENABLE_MONITORING="${ENABLE_MONITORING:-false}" \
	--env ENABLE_MATOMO="${ENABLE_MATOMO:-false}" \
	--workdir /flap_dir \
	"$CI_REGISTRY_IMAGE${CI_COMMIT_REF_SLUG}:${CI_COMMIT_SHA}" \
	/bin/sh -c "while true; do sleep 1000; done"

# Chose one of the following option:

# To copy the container's FLAP_DIR, use the following command from the docker container.
docker exec flap rm -rf /flap_dir/*
docker exec flap cp -rT /opt/flap /flap_dir

# To use your local files run the following command from your host machine.
# sudo rsync -a --delete $FLAP_DIR/* /flap_dir

docker exec flap flapctl stop

docker exec flap flapctl clean config -y
docker exec flap flapctl clean data -y

# Copy pipeline init_config file.
mkdir --parents /flap_data/system
cp /flap_dir/system/flapctl.examples.d/pipeline.env /flap_data/system/flapctl.env

docker exec flap ln -sf "/flap_dir/system/cli/flapctl.sh" /bin/flapctl

docker exec flap flapctl start

docker exec flap flapctl users create_admin
docker exec flap flapctl domains generate_local flap.test

docker exec flap git checkout "$CI_COMMIT_SHA"
docker exec flap flapctl update

# Install chromium: https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-on-alpine
apk add --no-cache \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-freefont

# Install nodejs and npm.
apk add nodejs npm make python

# Don't download chromium during puppeteer installation.
# shellcheck disable=SC2034
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

npm install codeceptjs puppeteer mocha-junit-reporter

# Run e2e tests
cd /flap_dir/home
npm run e2e:copy
eval "$(docker exec flap flapctl config show)"

npx codeceptjs run --profile=chrome-ci --steps
