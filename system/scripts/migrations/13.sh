#!/bin/bash

set -euo pipefail

echo "* [13] Use dynamic admin email."
echo "louis@chmn.me" > "$FLAP_DATA/system/admin_email.txt"
