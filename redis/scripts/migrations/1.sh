#!/bin/bash

set -euo pipefail

echo "* [1] Remove wrongly created directory."
rm --recursive --force "$FLAP_DATA/redis/config"
