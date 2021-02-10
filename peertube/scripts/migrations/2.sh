#!/bin/bash

set -eu

# Version v1.14.4

echo "* [2] Un fix peertube's saml plugin version."
docker-compose run -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2

echo "* [2] Stop started services."
flapctl stop
