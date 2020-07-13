#!/bin/bash

set -eu

# Version v1.12.0

echo "* [17] Generating TLS certificates to include home and exclude core."
flapctl tls generate_localhost
