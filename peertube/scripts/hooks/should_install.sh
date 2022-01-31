#!/bin/bash

set -euo pipefail


test "${ENABLE_PEERTUBE:-false}" == "true"
test "$ARCH" == "x86_64"
test "${PRIMARY_DOMAIN_NAME:-}" != ""
test "${PEERTUBE_DOMAIN_NAME:-}" != ""
