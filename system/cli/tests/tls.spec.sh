#!/bin/bash

set -e

EXIT=0

{
    echo "      - Generating TLS certificates"

    # Save FLAP data
    mkdir -p $FLAP_DATA/system/data
    mv $FLAP_DATA/system/data $FLAP_DATA/system/data.bak
    mkdir -p $FLAP_DATA/system/data

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir -p /etc/ssl/nginx

    # Setting test domain name
    echo "flap.localhost localhost _" > $FLAP_DATA/system/data/domainRequest.txt
    echo "WAITING" > $FLAP_DATA/system/data/domainRequestStatus.txt

    {
        # Generate certificates
        manager handle_domain_request &> /dev/null &&
        # Ensure certificates are created
        ls /etc/ssl/nginx | grep "privkey.key" > /dev/null &&
        ls /etc/ssl/nginx | grep "fullchain.crt" > /dev/null &&
        ls /etc/ssl/nginx | grep "chain.pem" > /dev/null &&
        # Ensure request is same as domain
        [ "$(cat $FLAP_DATA/system/data/domainInfo.txt)" == "$(cat $FLAP_DATA/system/data/domainRequest.txt)" ] &&
        # Ensure request status is OK
        [ "$(cat $FLAP_DATA/system/data/domainRequestStatus.txt)" == "OK" ]
    } || {
        echo "     ❌ 'manager handle_domain_request' failed to generate certificates."
        EXIT=1
    }

    # Unsave domainInfo.txt
    rm -rf $FLAP_DATA/system/data
    mv $FLAP_DATA/system/data.bak $FLAP_DATA/system/data

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

{
    echo "      - Generating TLS certificates of a OK domain"

    # Save FLAP data
    mkdir -p $FLAP_DATA/system/data
    mv $FLAP_DATA/system/data $FLAP_DATA/system/data.bak
    mkdir $FLAP_DATA/system/data

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir /etc/ssl/nginx

    # Setting OK domain name
    echo "flap.localhost localhost _" > $FLAP_DATA/system/data/domainRequest.txt
    echo "OK" > $FLAP_DATA/system/data/domainRequestStatus.txt

    {
        manager handle_domain_request &> /dev/null &&
        [ "$(cat $FLAP_DATA/system/data/domainRequestStatus.txt)" == "OK" ]
    } || {
        echo "     ❌ 'manager handle_domain_request' failed to generate certificates for a OK domain."
        EXIT=1
    }

    # Unsave domainInfo.txt
    rm -rf $FLAP_DATA/system/data
    mv $FLAP_DATA/system/data.bak $FLAP_DATA/system/data

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

exit $EXIT