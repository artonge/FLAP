#!/bin/bash

set -euo pipefail

test "${ENABLE_COLLABORA:-false}" == "true"
test "$ARCH" == "x86_64"
test "${PRIMARY_DOMAIN_NAME:-}" != ""
