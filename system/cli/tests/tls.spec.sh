#!/bin/bash

set -e

EXIT=0

{
    echo "      - Generating TLS certificates"

    # Save FLAP data
    mkdir -p $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains $FLAP_DATA/system/data/domains.bak
    mkdir -p $FLAP_DATA/system/data/domains

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir -p /etc/ssl/nginx

    # Mock certbot and cp
    mkdir -p /tmp/bin
    ln -sf $(which echo) /tmp/bin/certbot
    ln -sf $(which echo) /tmp/bin/cp
    export PATH=/tmp/bin:$PATH

    # Setting test domain name n°1
    mkdir $FLAP_DATA/system/data/domains/test1.duckdns.org
    echo "WAITING" > $FLAP_DATA/system/data/domains/test1.duckdns.org/status.txt
    echo "duckdns" > $FLAP_DATA/system/data/domains/test1.duckdns.org/provider.txt

    # Setting test domain name n°2
    mkdir $FLAP_DATA/system/data/domains/test2.duckdns.org
    echo "WAITING" > $FLAP_DATA/system/data/domains/test2.duckdns.org/status.txt
    echo "duckdns" > $FLAP_DATA/system/data/domains/test2.duckdns.org/provider.txt

    {
        # Generate certificates
        manager tls handle_request &> /dev/null &&
        # Ensure request status is OK
        [ "$(cat $FLAP_DATA/system/data/domains/test1.duckdns.org/status.txt)" == "OK" ] &&
        [ "$(cat $FLAP_DATA/system/data/domains/test2.duckdns.org/status.txt)" == "WAITING" ]
    } || {
        echo "     ❌ 'manager tls handle_request' failed to generate certificates."
        EXIT=1
    }

    # Unsave .../domains
    rm -rf $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains.bak $FLAP_DATA/system/data/domains

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx

    rm -rf /tmp/bin
}

{
    echo "      - Error during TLS certificates generation"

    # Save FLAP data
    mkdir -p $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains $FLAP_DATA/system/data/domains.bak
    mkdir -p $FLAP_DATA/system/data/domains

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir -p /etc/ssl/nginx

    # Setting test domain name n°1
    mkdir $FLAP_DATA/system/data/domains/test1.duckdns.org
    echo "WAITING" > $FLAP_DATA/system/data/domains/test1.duckdns.org/status.txt
    echo "duckdns" > $FLAP_DATA/system/data/domains/test1.duckdns.org/provider.txt

    # Setting test domain name n°2
    mkdir $FLAP_DATA/system/data/domains/test2.duckdns.org
    echo "WAITING" > $FLAP_DATA/system/data/domains/test2.duckdns.org/status.txt
    echo "duckdns" > $FLAP_DATA/system/data/domains/test2.duckdns.org/provider.txt

    {
        # Generate certificates
        ( manager tls handle_request &> /dev/null || true ) &&
        # Ensure request status is ERROR
        [ "$(cat $FLAP_DATA/system/data/domains/test1.duckdns.org/status.txt)" == "ERROR" ] &&
        [ "$(cat $FLAP_DATA/system/data/domains/test2.duckdns.org/status.txt)" == "WAITING" ]
    } || {
        echo "     ❌ 'manager tls handle_request' failed to set error."
        EXIT=1
    }

    # Unsave .../domains
    rm -rf $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains.bak $FLAP_DATA/system/data/domains

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx

    rm -rf /tmp/bin
}

{
    echo "      - Generating TLS certificates of a HANDLED domain"

    # Save FLAP data
    mkdir -p $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains $FLAP_DATA/system/data/domains.bak
    mkdir -p $FLAP_DATA/system/data/domains

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir -p /etc/ssl/nginx

    # Setting test domain name
    mkdir $FLAP_DATA/system/data/domains/test.duckdns
    echo "HANDLED" > $FLAP_DATA/system/data/domains/test.duckdns/status.txt
    echo "duckdns" > $FLAP_DATA/system/data/domains/test.duckdns/provider.txt

    {
        manager tls handle_request &> /dev/null &&
        [ "$(cat $FLAP_DATA/system/data/domains/test.duckdns/status.txt)" == "HANDLED" ]
    } || {
        echo "     ❌ 'manager tls handle_request' failed to generate certificates for a HANDLED domain."
        EXIT=1
    }

    # Unsave .../domains
    rm -rf $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains.bak $FLAP_DATA/system/data/domains

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

{
    echo "      - Generating TLS certificates of a OK domain"

    # Save FLAP data
    mkdir -p $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains $FLAP_DATA/system/data/domains.bak
    mkdir -p $FLAP_DATA/system/data/domains

    # Save user's certificates
    mkdir -p /etc/ssl/nginx
    mv /etc/ssl/nginx /etc/ssl/nginx.bak
    mkdir -p /etc/ssl/nginx

    # Setting test domain name
    mkdir $FLAP_DATA/system/data/domains/test.duckdns
    echo "OK" > $FLAP_DATA/system/data/domains/test.duckdns/status.txt
    echo "duckdns" > $FLAP_DATA/system/data/domains/test.duckdns/provider.txt

    {
        manager tls handle_request &> /dev/null &&
        [ "$(cat $FLAP_DATA/system/data/domains/test.duckdns/status.txt)" == "OK" ]
    } || {
        echo "     ❌ 'manager tls handle_request' failed to generate certificates for a OK domain."
        EXIT=1
    }

    # Unsave .../domains
    rm -rf $FLAP_DATA/system/data/domains
    mv $FLAP_DATA/system/data/domains.bak $FLAP_DATA/system/data/domains

    # Unsave user's certificates
    rm -rf /etc/ssl/nginx
    mv /etc/ssl/nginx.bak /etc/ssl/nginx
}

exit $EXIT