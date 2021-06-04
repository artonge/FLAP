#!/bin/bash

set -eu

debug "Restoring TLS certificates."
if [ -f "$FLAP_DATA/system/certificates.tar.gz" ]
then
	tar -xzvf "$FLAP_DATA/system/certificates.tar.gz" -C /
fi
