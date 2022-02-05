#!/bin/bash

set -euo pipefail

docker-compose logs nextcloud | grep --quiet "NOTICE: ready to handle connections"
