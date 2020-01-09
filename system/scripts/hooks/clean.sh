#!/bin/bash

set -eu

docker network rm flap_apps-net || true
docker network rm flap_stores-net || true
