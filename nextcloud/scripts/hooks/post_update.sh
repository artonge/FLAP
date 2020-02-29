#!/bin/bash

set -eu

# Wait for nextcloud to finish any kind of update routine.
"$FLAP_DIR/nextcloud/scripts/wait_ready.sh"
