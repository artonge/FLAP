#!/bin/bash

set -e

# Move domain info to support multiple domain names

domain_name=$(cat $FLAP_DATA/system/data/domainInfo.txt | cut -d ' ' -f1)
domain_provider=$(cat $FLAP_DATA/system/data/domainInfo.txt | cut -d ' ' -f2)
domain_auth=$(cat $FLAP_DATA/system/data/domainInfo.txt | cut -d ' ' -f3)
domain_status=$(cat $FLAP_DATA/system/data/domainInfo.txt | cut -d ' ' -f4)

mkdir -p $FLAP_DATA/system/data/domains/$domain_name

echo $domain_status > $FLAP_DATA/system/data/domains/$domain_name/status.txt
echo "$domain_provider $domain_auth" > $FLAP_DATA/system/data/domains/$domain_name/provider.txt