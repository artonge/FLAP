#!/bin/bash

set -euo pipefail

echo "* [5] Generate smaller avatar."
# For v4.2.0: https://framagit.org/framasoft/peertube/PeerTube/-/blob/develop/CHANGELOG.md#v420
docker-compose exec -T --user peertube peertube node dist/scripts/migrations/peertube-4.2.js

echo "* [5] Update saml2 plugin to version 0.0.6."
docker-compose run -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2 --plugin-version 0.0.6
