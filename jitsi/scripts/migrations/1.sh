#!/bin/bash

set -eu

echo "* [1] Allow connexions to port 5349"
ufw allow 5349
