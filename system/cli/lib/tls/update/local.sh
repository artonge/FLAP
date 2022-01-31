#!/bin/bash

set -euo pipefail

DOMAIN=$1

echo "* [dns-update:local] Provider is local for $DOMAIN, there is nothing to do."
