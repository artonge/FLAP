#!/bin/bash

set -eu

test "${ENABLE_JITSI:-true}" == "true"

test "$ARCH" == "x86_64"
