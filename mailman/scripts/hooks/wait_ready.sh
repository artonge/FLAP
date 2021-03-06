#!/bin/bash

set -eu

until docker-compose logs mailman_web | grep "getting INI configuration from /opt/mailman-web/uwsgi.ini" > /dev/null
do
    debug "Mailman web is unavailable - sleeping"
    sleep 1
done

until docker-compose logs mailman_core | grep "Using Postfix configuration" > /dev/null
do
    debug "Mailman core is unavailable - sleeping"
    sleep 1
done
