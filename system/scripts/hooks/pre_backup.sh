#!/bin/bash

set -eu

echo "Archiving TLS certificates."
tar -zcf "$FLAP_DATA/system/certificates.tar.gz" /etc/letsencrypt