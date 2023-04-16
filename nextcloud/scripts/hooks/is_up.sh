#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs nextcloud)
echo "$logs" | grep "NOTICE: ready to handle connections"
