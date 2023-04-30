#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs mail)
echo "$logs" | grep --quiet "is up and running"
