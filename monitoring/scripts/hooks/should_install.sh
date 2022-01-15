#!/bin/bash

set -euo pipefail


test "${ENABLE_MONITORING:-false}" == "true"
