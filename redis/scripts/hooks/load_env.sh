#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${REDIS_PWD}"

export REDIS_PWD
REDIS_PWD=$(generatePassword redis redis_pwd)
