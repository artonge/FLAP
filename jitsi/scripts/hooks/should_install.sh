#!/bin/bash

set -eu

test "${ENABLE_JITSI:-false}" == "true"

test "$ARCH" == "x86_64"
