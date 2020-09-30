#!/bin/bash

set -eu

echo "* [1] Remove wrongly created directory."
rm --force "$FLAP_DATA/redis/config"
