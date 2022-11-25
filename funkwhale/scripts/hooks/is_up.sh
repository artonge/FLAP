#!/bin/bash

set -euo pipefail

logs=$(docker compose logs funkwhale_api)
echo "$logs" | grep --quiet "Application startup complete."
