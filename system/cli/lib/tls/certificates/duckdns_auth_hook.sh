#!/bin/bash

# Usage: ./duckdnsAuthHook.sh <duckdns token>

DUCKDNS_TOKEN=$1

curl --silent https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}\&token=${DUCKDNS_TOKEN}\&txt=${CERTBOT_VALIDATION} > /dev/null
