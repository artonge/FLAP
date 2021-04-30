#!/bin/bash

set -eu

test "${ENABLE_MONITORING:-false}" == "true"
