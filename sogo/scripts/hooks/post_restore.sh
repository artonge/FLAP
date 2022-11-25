#!/bin/bash

set -euo pipefail


docker compose --ansi never up --detach sogo

for user in "$FLAP_DIR"/sogo/backup/*
do
	[[ -e "$user" ]] || break  # handle the case of no users.

	debug "Restoring $user"

	user=$(basename "$user")
	debug "Restoring $user"
	docker exec --user sogo flap_sogo sogo-tool restore -f ALL /backup "$user"
done
