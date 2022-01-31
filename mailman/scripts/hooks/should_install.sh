#!/bin/bash

set -euo pipefail


test "${ENABLE_MAILMAN:-false}" == "true"
test "$ARCH" == "x86_64"
