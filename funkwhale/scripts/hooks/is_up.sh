#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs funkwhale_api)
echo "$logs" | grep "Application startup complete."
