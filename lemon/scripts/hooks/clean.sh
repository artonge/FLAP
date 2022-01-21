#!/bin/bash

set -euo pipefail

if ! is_service_up lemon && ! is_service_up nginx
then
	docker volume rm --force flap_lemonStaticFiles
fi
