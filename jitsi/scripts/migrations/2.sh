#!/bin/bash

set -eu

echo "* [2] Remove port in turn_server.txt"

echo "$TURN_SERVER" | cut -d ':' -f1 > "$FLAP_DATA/system/data/turn_server.txt"
