#!/bin/bash

set -eu

echo "Giving permission to weblate user to access file in /app/data."
docker-compose run --rm --user root --entrypoint 'bash -c' weblate '/bin/chown weblate:weblate /app/data'
