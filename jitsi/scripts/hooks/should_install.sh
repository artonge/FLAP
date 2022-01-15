#!/bin/bash

set -euo pipefail


test "${ENABLE_JITSI:-false}" == "true"

test "$ARCH" == "x86_64"
