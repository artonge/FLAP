#!/bin/bash

set -euo pipefail

logs=$(docker-compose logs mail)
echo "$logs" | grep "is up and running"
