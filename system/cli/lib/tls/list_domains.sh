#!/bin/bash

set -eu

mkdir -p "$FLAP_DATA/system/data/domains"

for domain in "$FLAP_DATA"/system/data/domains/*
do
	[[ -e "$domain" ]] || break  # handle the case of no domain
    echo "$(basename "$domain") - $(cat "$domain/status.txt") - $(cat "$domain/provider.txt")"
done
