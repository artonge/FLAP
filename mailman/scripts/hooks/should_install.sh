#!/bin/bash

set -euo pipefail


test "${ENABLE_MAILMAN:-false}" == "true"
# Mailman has no image for arm64v8.
test "$ARCH" == "x86_64"
