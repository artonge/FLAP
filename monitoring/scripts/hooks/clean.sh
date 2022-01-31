#!/bin/bash

set -euo pipefail

debug "Cleaning networks."
if docker network ls | grep --quiet flap_monitor-net
then
	docker network rm flap_monitor-net || true
fi
