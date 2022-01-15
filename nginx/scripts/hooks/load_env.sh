#!/bin/bash

set -euo pipefail


# 80 - HTTP
# 443 - HTTPS
NEEDED_PORTS="$NEEDED_PORTS 80/tcp 443/tcp"
