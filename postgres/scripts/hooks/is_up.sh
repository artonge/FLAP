#!/bin/bash

set -euo pipefail

docker-compose logs postgres | grep --quiet "database system is ready to accept connections"
