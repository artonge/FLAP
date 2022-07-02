#!/bin/bash

set -euo pipefail

test "${ENABLE_PEERTUBE:-false}" == "true"
test "${PRIMARY_DOMAIN_NAME:-}" != ""
test "${PEERTUBE_DOMAIN_NAME:-}" != ""
