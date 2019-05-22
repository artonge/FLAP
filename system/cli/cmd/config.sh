#!/bin/bash

set -e

CMD=$1

# Read password from file.
# If the file does not exists, create it and generate a password.
readPwd() {
    mkdir -p /var/lib/manager

    if [ ! -f $1 ]
    then
        openssl rand --hex 32 > $1
    fi

    cat $1
}

# Create default domainInfo.txt if it is missing
if [ ! -f /var/lib/manager/domainInfo.txt ]
then
    mkdir -p /var/lib/manager
    echo "flap.local local" > /var/lib/manager/domainInfo.txt
fi

DOMAIN_INFO=$(cat /var/lib/manager/domainInfo.txt)
export DOMAIN_NAME=$(echo $DOMAIN_INFO | cut -d ' ' -f1)

# Read passwords from files
export ADMIN_PWD=$(readPwd /var/lib/manager/adminPwd.txt)
export SOGO_DB_PWD=$(readPwd /var/lib/manager/sogoDbPwd.txt)
export NEXTCLOUD_DB_PWD=$(readPwd /var/lib/manager/nextcloudDbPwd.txt)

case $CMD in
    generate)
        DIR=$(dirname "$(readlink -f "$0")")

        # Nginx
        echo "Generating configurations for Nginx"
        envsubst < $DIR/../../../nginx/config/nginx.template.conf > $DIR/../../../nginx/config/nginx.conf
        envsubst < $DIR/../../../nginx/config/conf.d/flap.template.conf > $DIR/../../../nginx/config/conf.d/flap.conf
        envsubst < $DIR/../../../nginx/config/conf.d/sogo.template.conf > $DIR/../../../nginx/config/conf.d/sogo.conf
        envsubst < $DIR/../../../nginx/config/conf.d/nextcloud.template.conf > $DIR/../../../nginx/config/conf.d/nextcloud.conf
        # PostgreSQL
        echo "Generating configurations for PostgreSQL"
        envsubst < $DIR/../../../postgres/scripts/setup.template.sql > $DIR/../../../postgres/scripts/setup.sql
        envsubst < $DIR/../../../postgres/postgres.template.env > $DIR/../../../postgres/postgres.env
        # LDAP
        echo "Generating configurations for LDAP"
        envsubst < $DIR/../../../ldap/ldap.template.env > $DIR/../../../ldap/ldap.env
        # FLAP core
        echo "Generating configurations for FLAP core"
        envsubst < $DIR/../../../core/core.template.env > $DIR/../../../core/core.env
        # Nextcloud
        echo "Generating configurations for nextcloud"
        envsubst < $DIR/../../../nextcloud/nextcloud.template.env > $DIR/../../../nextcloud/nextcloud.env
        # SOGo
        echo "Generating configurations for SOGo"
        envsubst < $DIR/../../../sogo/config/sogo.template.conf > $DIR/../../../sogo/config/sogo.conf
        envsubst < $DIR/../../../sogo/sogo.template.env > $DIR/../../../sogo/sogo.env
        ;;
    show)
        echo "DOMAIN_INFO=$DOMAIN_INFO"
        echo "ADMIN_PWD=$ADMIN_PWD"
        echo "SOGO_DB_PWD=$SOGO_DB_PWD"
        echo "NEXTCLOUD_DB_PWD=$NEXTCLOUD_DB_PWD"
        ;;
    summarize)
        echo "config | [generate, show, help] | Generate the configuration for each services."
        ;;
    help|*)
        echo "
config | Generate the configuration for each services.
Commands:
    generate | | Generate the services config files from the current config variables.
    show | | Show the current config variables." | column --table --separator "|"
        ;;
esac
