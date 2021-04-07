#!/bin/bash

set -eu

until docker-compose exec mailman_web mailman status | grep "[uWSGI] getting INI configuration from /opt/mailman-web/uwsgi.ini" > /dev/null
do
    echo "Mailman web is unavailable - sleeping"
    sleep 1
done

until docker-compose logs mailman_core | grep "Using Postfix configuration" > /dev/null
do
    echo "Mailman core is unavailable - sleeping"
    sleep 1
done
