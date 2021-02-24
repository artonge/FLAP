#!/bin/bash

set -eu

test "${ENABLE_MATRIX:-true}" == "true"

# Do not install matrix if MATRIX_DOMAIN_NAME is not set.
test "${MATRIX_DOMAIN_NAME:-}" != ""
