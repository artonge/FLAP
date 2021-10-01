#!/bin/bash

set -eu

test "${ENABLE_WORDPRESS:-false}" == "true"
