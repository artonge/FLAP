#!/bin/bash

set -euo pipefail


test "${ENABLE_NEXTCLOUD:-false}" == "true"
