#!/bin/bash

set -eu

# v1.23.0

flapctl start peertube
docker-compose exec -T --user peertube peertube node dist/scripts/migrations/peertube-4.0.js
flapctl stop peertube
