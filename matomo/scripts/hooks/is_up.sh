#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs matomo)
echo "$logs" | grep --quiet "NOTICE: ready to handle connections"
