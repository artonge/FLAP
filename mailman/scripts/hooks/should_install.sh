#!/bin/bash

set -eu

test "${ENABLE_MAILMAN:-false}" == "true"
test "$ARCH" == "x86_64"
