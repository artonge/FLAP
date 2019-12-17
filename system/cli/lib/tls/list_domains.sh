#!/bin/bash

set -eu

mkdir -p $FLAP_DATA/system/data/domains

for domain in $(ls $FLAP_DATA/system/data/domains)
do
    status=$(cat $FLAP_DATA/system/data/domains/$domain/status.txt)
    provider=$(cat $FLAP_DATA/system/data/domains/$domain/provider.txt | cut -d ' ' -f1)

    echo "$domain - $status - $provider"
done
