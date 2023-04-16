#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs matomo)
echo "$logs" | grep "NOTICE: ready to handle connections"
