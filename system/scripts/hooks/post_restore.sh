#!/bin/bash

set -euo pipefail


debug "Restoring TLS certificates."
if [ -f "$FLAP_DATA/system/certificates.tar.gz" ]
then
	tar -xzvf "$FLAP_DATA/system/certificates.tar.gz" -C /
fi
