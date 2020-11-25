#!/bin/bash

set -eu

# Mariadb has no image for armv7
test "$ARCH" == "x86_64"
