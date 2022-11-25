#!/bin/bash

set -euo pipefail

if ! is_service_up peertube && ! is_service_up nginx
then
	docker volume rm --force flap_peertubeStaticFiles
fi
