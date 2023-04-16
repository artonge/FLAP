#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs mailman_web)
echo "$logs" | grep "getting INI configuration from /opt/mailman-web/uwsgi.ini"

logs=$(docker-compose logs mailman_core)
echo "$logs" | grep "Using Postfix configuration"
