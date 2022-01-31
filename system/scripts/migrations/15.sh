#!/bin/bash

set -euo pipefail

# Version v1.10.0

echo "* [15] Install restic and borg."
apt-get install -y restic borgbackup
