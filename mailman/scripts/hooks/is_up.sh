#!/bin/bash

set -euo pipefail

docker-compose logs mailman_web | grep --quiet "getting INI configuration from /opt/mailman-web/uwsgi.ini"
docker-compose logs mailman_core | grep --quiet "Using Postfix configuration"
