#!/bin/bash

set -euo pipefail


test "${ENABLE_MATOMO:-false}" == "true"

# Mariadb has no image for armv7.
test "$ARCH" == "x86_64"

# Need a domain to finish the setup.
test "${PRIMARY_DOMAIN_NAME:-}" != ""

# Need admin email to send mail.
test "${ADMIN_EMAIL:-}" != ""
