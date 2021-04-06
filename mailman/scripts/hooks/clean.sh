#!/bin/bash

set -eu

docker volume rm --force mailmanStaticFiles || true
