#!/bin/bash

set -euo pipefail


docker volume rm --force flap_lemonStaticFiles || true
