#!/bin/bash

set -euo pipefail

test "$(docker-compose exec -T ldap ldapwhoami -x -D cn=admin,dc=flap,dc=local -w "$ADMIN_PWD")" == "dn:cn=admin,dc=flap,dc=local"
