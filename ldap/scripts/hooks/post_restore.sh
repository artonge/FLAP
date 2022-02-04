#!/bin/bash

set -euo pipefail

debug "Deleting ldap config."
rm -rf "$FLAP_DATA"/ldap/config/*

debug "Booting up fresh ldap instance."
flapctl start ldap

debug "Deleting ldap data."
rm -rf "$FLAP_DATA"/ldap/data/*

debug "Restoring ldap users."
gzip --decompress --stdout "$FLAP_DATA/ldap/backup.ldif.gz" | docker-compose exec --user openldap -T ldap slapadd -n1 -F /etc/ldap/slapd.d

debug "Stopping ldap container."
flapctl stop ldap
