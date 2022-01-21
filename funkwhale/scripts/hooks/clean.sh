#!/bin/bash

set -euo pipefail

if ! is_service_up funkwhale && ! is_service_up nginx
then
	docker volume rm --force flap_funkwhaleStaticFiles
	docker volume rm --force flap_funkwhaleFrontend
fi

