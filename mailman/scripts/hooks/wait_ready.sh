#!/bin/bash

set -euo pipefail

until docker-compose logs mailman_web | grep --quiet "getting INI configuration from /opt/mailman-web/uwsgi.ini"
do
    debug "Mailman web is unavailable - sleeping"
    sleep 1
done

until docker-compose logs mailman_core | grep --quiet "Using Postfix configuration"
do
    debug "Mailman core is unavailable - sleeping"
    sleep 1
done
