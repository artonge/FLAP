#!/bin/bash

set -eu

until docker-compose logs wordpress | grep "NOTICE: ready to handle connections" > /dev/null
do
    debug "Wordpress is unavailable - sleeping"
    sleep 1
done
