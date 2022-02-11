#!/bin/bash

set -euo pipefail

echo "* [25] Update certbot renewal hooks."
flapctl setup certbot_renewal_hooks
