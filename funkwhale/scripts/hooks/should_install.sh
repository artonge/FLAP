#!/bin/bash

set -euo pipefail


test "${ENABLE_FUNKWHALE:-false}" == "true"
test "${PRIMARY_DOMAIN_NAME:-}" != ""
test "${FUNKWHALE_DOMAIN_NAME:-}" != ""
