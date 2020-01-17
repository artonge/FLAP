#!/bin/bash

set -eu

docker network rm flap_apps-net || true
docker network rm flap_stores-net || true

# HACK: also remove 'flap_dir' networks to allow piepline to succeed.
# Remove after v1.0.12
docker network rm flap_dir_apps-net || true
docker network rm flap_dir_stores-net || true
