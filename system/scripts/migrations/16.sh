#!/bin/bash

set -eu

# Version v1.11.0

echo "* [16] Init flap.conf file."
touch "$FLAP_DATA/system/flap.conf"
