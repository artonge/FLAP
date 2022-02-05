#!/bin/bash

set -euo pipefail

docker-compose logs matomo | grep --quiet "NOTICE: ready to handle connections"
