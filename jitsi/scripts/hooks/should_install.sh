#!/bin/bash

set -euo pipefail


test "${ENABLE_JITSI:-false}" == "true"
