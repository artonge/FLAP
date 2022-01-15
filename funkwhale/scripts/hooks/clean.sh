#!/bin/bash

set -euo pipefail

docker volume rm --force flap_funkwhaleStaticFiles || true
docker volume rm --force flap_funkwhaleFrontend || true
