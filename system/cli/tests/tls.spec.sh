#!/bin/bash

set -e

EXIT=0

{
    echo "      - Generating TLS certificates"

    # Save FLAP data
    mkdir -p $FLAP_DATA
    mv $FLAP_DATA $FLAP_DATA.bak
    mkdir -p $FLAP_DATA

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak

    # Setting test domain name
    echo "flap.localhost localhost _" > $FLAP_DATA/domainRequest.txt
    echo "WAITING" > $FLAP_DATA/domainRequestStatus.txt

    {
        # Generate certificates
        manager tls generate > /dev/null &&
        # Ensure certificates are created
        ls /etc/ssl/nginx | grep "privkey.key" > /dev/null &&
        ls /etc/ssl/nginx | grep "fullchain.crt" > /dev/null &&
        ls /etc/ssl/nginx | grep "chain.pem" > /dev/null &&
        # Ensure request is same as domain
        [ "$(cat $FLAP_DATA/domainInfo.txt)" == "$(cat $FLAP_DATA/domainRequest.txt)" ] &&
        # Ensure request status is OK
        [ "$(cat $FLAP_DATA/domainRequestStatus.txt)" == "OK" ]
    } || {
        echo "     ❌ 'manager tls generate' failed to generate certificates."
        EXIT=1
    }

    # Unsave domainInfo.txt
    rm -rf $FLAP_DATA
    mv $FLAP_DATA.bak $FLAP_DATA

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

{
    echo "      - Generating TLS certificates of a OK domain"

    # Save FLAP data
    mkdir -p $FLAP_DATA
    mv $FLAP_DATA $FLAP_DATA.bak
    mkdir $FLAP_DATA

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir /etc/ssl/nginx

    # Setting OK domain name
    echo "flap.localhost localhost _" > $FLAP_DATA/domainRequest.txt
    echo "OK" > $FLAP_DATA/domainRequestStatus.txt

    {
        manager tls generate > /dev/null &&
        [ "$(cat $FLAP_DATA/domainRequestStatus.txt)" == "OK" ]
    } || {
        echo "     ❌ 'manager tls generate' failed to generate certificates for a OK domain."
        EXIT=1
    }

    # Unsave domainInfo.txt
    rm -rf $FLAP_DATA
    mv $FLAP_DATA.bak $FLAP_DATA

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

exit $EXIT