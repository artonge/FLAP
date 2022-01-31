#!/bin/bash

set -euo pipefail


test "${ENABLE_WEBLATE:-false}" == "true"

test "$ARCH" == "x86_64"
