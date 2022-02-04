#!/bin/bash

set -euo pipefail

docker-compose logs mail | grep --quiet "daemon started"
