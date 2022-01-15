#!/bin/bash

set -euo pipefail

# Version v1.13.1

echo "* [19] Syncing git remote after changing home's remote."
git submodule sync
