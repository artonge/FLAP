#!/bin/bash

set -eu

# Version v1.14.3

echo "* [1] Update saml2 plugin to version 0.0.2."
docker-compose run -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2 --plugin-version 0.0.2
# Stop started services associated to peertube.
flapctl stop
