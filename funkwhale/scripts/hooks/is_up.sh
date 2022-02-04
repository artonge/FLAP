#!/bin/bash

set -euo pipefail

docker-compose logs funkwhale_api | grep --quiet "Application startup complete."
