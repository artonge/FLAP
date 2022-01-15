#!/bin/bash

set -euo pipefail


echo "Update SAML auth plugin."
docker-compose exec -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2 --plugin-version "$PEERTUBE_SAML_PLUGIN_VERSION"
