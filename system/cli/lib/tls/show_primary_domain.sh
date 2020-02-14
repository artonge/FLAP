#!/bin/bash

set -eu

mkdir -p "$FLAP_DATA/system/data"
touch "$FLAP_DATA/system/data/primary_domain.txt"
cat "$FLAP_DATA/system/data/primary_domain.txt"
