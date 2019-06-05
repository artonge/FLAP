#!/bin/bash

set -e

EXIT=0

{
    echo "      - Generating TLS certificates"

    # Save current domainInfo.txt
    if [ -f $FLAP_DATA/domainInfo.txt ]
    then
        mv $FLAP_DATA/domainInfo.txt $FLAP_DATA/domainInfo.txt.bak
    fi

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir /etc/ssl/nginx

    # Setting test domain name
    echo "flap.localhost localhost _" > $FLAP_DATA/domainInfo.txt

    {
        # Generate certificates
        manager tls generate > /dev/null &&
        # Ensure certificates are created
        ls /etc/ssl/nginx | grep "privkey.key" > /dev/null &&
        ls /etc/ssl/nginx | grep "fullchain.crt" > /dev/null &&
        ls /etc/ssl/nginx | grep "chain.pem" > /dev/null &&
        # Ensure domainInfo.txt is marked as OK
        cat $FLAP_DATA/domainInfo.txt | grep -E "OK$" > /dev/null
    } || {
        echo "     ❌ 'manager tls generate' failed to generate certificates."
        EXIT=1
    }

    # Unsave domainInfo.txt
    if [ -f $FLAP_DATA/domainInfo.txt.bak ]
    then
        rm $FLAP_DATA/domainInfo.txt
        mv $FLAP_DATA/domainInfo.txt.bak $FLAP_DATA/domainInfo.txt
    fi

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

{
    echo "      - Generating TLS certificates of a OK domain"

    # Save current domainInfo.txt
    if [ -f $FLAP_DATA/domainInfo.txt ]
    then
        mv $FLAP_DATA/domainInfo.txt $FLAP_DATA/domainInfo.txt.bak
    fi

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir /etc/ssl/nginx

    # Setting OK domain name
    echo "flap.localhost localhost _ OK" > $FLAP_DATA/domainInfo.txt

    {
        manager tls generate > /dev/null &&
        (manager tls show || echo "") | grep -v "flap.localhost" > /dev/null
    } || {
        echo "     ❌ 'manager tls generate' failed to generate certificates for a OK domain."
        EXIT=1
    }

    # Unsave domainInfo.txt
    if [ -f $FLAP_DATA/domainInfo.txt.bak ]
    then
        rm $FLAP_DATA/domainInfo.txt
        mv $FLAP_DATA/domainInfo.txt.bak $FLAP_DATA/domainInfo.txt
    fi

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

exit $EXIT