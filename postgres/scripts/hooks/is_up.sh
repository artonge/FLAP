#!/bin/bash

set -euo pipefail

# Store postgres' logs into a tmp variable because it exits with an error sometime.
# No idea why, but if streamlined and CI passes, then it should be safe to keep.
postgresLogs=$(docker-compose logs postgres)
echo "$postgresLogs" | grep --quiet "database system is ready to accept connections"
