#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs nextcloud)
echo "$logs" | grep --quiet "NOTICE: ready to handle connections"
