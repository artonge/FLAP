#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs peertube)
echo "$logs" | grep "listening on 0.0.0.0:9000"
