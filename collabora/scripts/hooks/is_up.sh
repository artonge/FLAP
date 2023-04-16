#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs collabora)
echo "$logs" | grep "Ready to accept connections on port 9980."
