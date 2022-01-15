#!/bin/bash

set -euo pipefail


# 25 - SMTP
# 587 - SMTP with STARTLS
# 143 - IMAP
NEEDED_PORTS="$NEEDED_PORTS 25/tcp 587/tcp 143/tcp"
