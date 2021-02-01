#!/bin/bash

set -eu

docker volume rm --force flap_funkwhaleStaticFiles || true
