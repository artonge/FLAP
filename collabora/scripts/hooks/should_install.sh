#!/bin/bash

set -eu

test "${ENABLE_COLLABORA:-false}" == "true"
test "$ARCH" == "x86_64"
# test "${PRIMARY_DOMAIN_NAME:-}" != ""
