#!/bin/bash

set -eu

# Version v1.14.2

echo "* [1] Fix email encryption setting."
docker-compose run --rm matomo php /var/www/html/console config:set --section="mail" --key="encryption" --value="tls"

echo "* [1] Stop ldap and mariadb."
docker-compose down
