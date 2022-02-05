#!/bin/bash

set -euo pipefail

docker-compose logs peertube | grep --quiet "listening on 0.0.0.0:9000"
