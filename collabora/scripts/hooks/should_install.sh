#!/bin/bash

set -euo pipefail

test "${ENABLE_COLLABORA:-false}" == "true"
test "${PRIMARY_DOMAIN_NAME:-}" != ""
