#!/bin/bash

set -eu

test "${ENABLE_MATRIX:-false}" == "true"
test "${PRIMARY_DOMAIN_NAME:-}" != ""
test "${MATRIX_DOMAIN_NAME:-}" != ""
