#!/bin/bash

set -euo pipefail

echo "* [3] Remove legacy config file riot.json."
rm --force "$FLAP_DIR/matrix/config/riot.json"
