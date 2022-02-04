#!/bin/bash

set -euo pipefail


debug "Give write access to the www-data user in the lemon's container."
chmod o+w "$FLAP_DATA/lemon/data"
