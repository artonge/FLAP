#!/bin/bash

set -euo pipefail

docker-compose exec -T postgres pg_isready | grep "accepting connections"
