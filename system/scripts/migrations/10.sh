#!/bin/bash

set -eu

if [ "$ARCH" != "x86_64" ]
then
	echo "* [10] Tweak homeservers feature flags to use external Jitsi and TURN server"
	echo "export FLAG_SYNAPSE_USE_EXTERNAL_JITSI_SERVER=true" > "$FLAP_DIR/flapctl.env"
	echo "export FLAG_JITSI_USE_EXTERNAL_TURN=true" >> "$FLAP_DIR/flapctl.env"
fi
