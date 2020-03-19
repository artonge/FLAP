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
	--volume /flap_data:/flap_data \
	--volume /flap_dir:/flap_dir \
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
	--volume /flap_data:/flap_data \
	--volume /flap_dir:/flap_dir \
	--volume /etc/letsencrypt/live/flap:/etc/letsencrypt/live/flap \
	--link docker \
	--add-host="flap.local:$FLAP_IP" \
	--add-host="flap.test:$FLAP_IP" \
	--add-host="auth.flap.test:$FLAP_IP" \
	--add-host="files.flap.test:$FLAP_IP" \
	--add-host="mail.flap.test:$FLAP_IP" \
	docker:stable \
	sh

# Specify the image we cant to debug.
CI_REGISTRY_IMAGE=registry.gitlab.com/flap-box/flap
CI_COMMIT_REF_SLUG=feature-support-flap-id-domains
CI_COMMIT_SHA=latest

FLAP_IP=$(grep docker /etc/hosts | cut -f1)

# Run the specified FLAP images.
# Pass some flags env var.
# Share the docker container network with this container so it can talk to itself.
#  ==> the network ports are beeing serve from the DinD container, that can be reach from the docker container but not from this container if we do not share the host network stack.
# Add entry to the /etc/hosts file to resolve flap.local and *.flap.test
# Bind our working directories.
docker run \
	--name flap \
	--detach \
	--env FLAG_NO_CLEAN_DOCKER=true \
	--env FLAG_NO_RAID_SETUP=true \
	--env FLAG_NO_NETWORK_SETUP=true \
	--env FLAG_NO_TLS_GENERATION=true \
	--env FLAG_INSECURE_SAML_FETCH=true \
	--env FLAG_USE_FIXED_IP=true \
	--env LOG_DRIVER=json-file \
	--network host \
	--add-host="flap.local:$FLAP_IP" \
	--add-host="flap.test:$FLAP_IP" \
	--add-host="auth.flap.test:$FLAP_IP" \
	--add-host="files.flap.test:$FLAP_IP" \
	--add-host="mail.flap.test:$FLAP_IP" \
	--volume /var/run/docker.sock:/var/run/docker.sock \
	--volume /flap_dir:/flap_dir \
	--volume /flap_data:/flap_data \
	--volume /etc/letsencrypt/live/flap:/etc/letsencrypt/live/flap \
	--env FLAP_DIR=/flap_dir \
	--env FLAP_DATA=/flap_data \
	$CI_REGISTRY_IMAGE/${CI_COMMIT_REF_SLUG}:${CI_COMMIT_SHA} \
	/bin/sh -c "while true; do sleep 1000; done"

docker exec flap flapctl stop
docker exec flap flapctl clean data -y

mkdir -p "/flap_data/system/data"
echo "0.0.0.0" > "/flap_data/system/data/fixed_ip.txt"

docker exec flap flapctl start

docker exec flap flapctl users create_admin
docker exec flap flapctl tls generate_localhost flap.test

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
cd /flap_dir/core
export FLAP_URL=flap.test
npx codeceptjs run --profile=chrome-ci --reporter mocha-junit-reporter
