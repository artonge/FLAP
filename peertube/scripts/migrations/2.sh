#!/bin/bash

set -eu

# Version v1.14.4

echo "* [2] Update saml2 plugin to version 0.0.4."
docker-compose run -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2 --plugin-version 0.0.4

echo "* [2] Stop started services."
flapctl stop
