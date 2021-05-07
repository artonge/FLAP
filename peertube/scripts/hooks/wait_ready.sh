#!/bin/bash

set -eu

until docker-compose logs peertube | grep "listening on 0.0.0.0:9000" > /dev/null
do
    debug "Peertube is unavailable - sleeping"
    sleep 1
done
