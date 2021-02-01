#!/bin/bash

set -eu

test "${ENABLE_FUNKWHALE:-false}" == "true"
test "$ARCH" == "x86_64"
test "${FUNKWHALE_DOMAIN_NAME:-}" != ""
