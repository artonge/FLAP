#!/bin/bash

set -euo pipefail


# Mariadb has no image for armv7
test "$ARCH" == "x86_64"
