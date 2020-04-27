#!/bin/bash

set -eu

test "${ENABLE_WEBLATE:-false}" == "true"

test "$ARCH" == "x86_64"
