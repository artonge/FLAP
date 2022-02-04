#!/bin/bash

set -euo pipefail

docker-compose logs collabora | grep --quiet "Ready to accept connections on port 9980."
