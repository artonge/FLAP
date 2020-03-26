#!/bin/bash

set -eu

if docker network ls | grep flap_apps-net
then
	docker network rm flap_apps-net
fi

if docker network ls | grep flap_stores-net
then
	docker network rm flap_stores-net
fi
