#!/bin/bash

set -eu

docker volume rm --force flap_peertubeStaticFiles || true
