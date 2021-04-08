#!/bin/bash

set -eu

echo "Archiving TLS certificates."
tar -zcvf "$FLAP_DATA/system/certificates.tar.gz" /etc/letsencrypt/live