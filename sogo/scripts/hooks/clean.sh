#!/bin/bash

set -euo pipefail

if ! is_service_up sogo && ! is_service_up nginx
then
	docker volume rm --force flap_sogoStaticFiles
fi
