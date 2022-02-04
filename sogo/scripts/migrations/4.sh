#!/bin/bash

set -euo pipefail


echo "* [4] Remove legacy stunnel config file."
rm --force "$FLAP_DIR/sogo/config/stunnel.conf"
