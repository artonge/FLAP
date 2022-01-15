#!/bin/bash

set -euo pipefail

DOMAIN=$1

echo "* [dns-update:unknown] Provider is not known, skipping for $DOMAIN."
