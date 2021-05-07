#!/bin/bash

set -eu

debug "Cleaning networks."
if docker network ls | grep flap_monitor-net
then
	docker network rm flap_monitor-net || true
fi
