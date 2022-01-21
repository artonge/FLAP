#!/bin/bash

set -euo pipefail


if ! is_service_up mailman && ! is_service_up nginx
then
	docker volume rm --force flap_mailmanStaticFiles
fi