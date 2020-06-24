#!/bin/bash

set -eu

echo "Cleaning networks."
if docker network ls | grep flap_apps-net
then
	docker network rm flap_apps-net || true
fi

if docker network ls | grep flap_stores-net
then
	docker network rm flap_stores-net || true
fi
