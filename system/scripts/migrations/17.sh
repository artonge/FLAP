#!/bin/bash

set -eu

# Version v1.12.0

echo "* [17] Generating TLS certificates to include home and exclude core."
flapctl tls generate

echo "* [17] Deleting legacy core submodule."
rm -rf "$FLAP_DIR/core"

echo "* [17] Mooving core' data to home."
mv "$FLAP_DATA/core" "$FLAP_DATA/home"
