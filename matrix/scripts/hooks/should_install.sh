#!/bin/bash

set -eu

test "${ENABLE_MATRIX:-false}" == "true"

# Do not install matrix if MATRIX_DOMAIN_NAME is not set.
test "${MATRIX_DOMAIN_NAME:-}" != ""
