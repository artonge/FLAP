#!/bin/bash

set -euo pipefail


docker volume rm --force mailmanStaticFiles || true
