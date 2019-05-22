#!/bin/bash

set -e

CMD=$1

# Read password from file.
# If the file does not exists, create it and generate a password.
readPwd() {
    mkdir -p /var/lib/flap

    if [ ! -f $1 ]
    then
        openssl rand --hex 32 > $1
    fi

    cat $1
}

# Create default domainInfo.txt if it is missing
if [ ! -f /var/lib/flap/domainInfo.txt ]
then
    mkdir -p /var/lib/flap
    echo "flap.local local" > /var/lib/flap/domainInfo.txt
fi

DOMAIN_INFO=$(cat /var/lib/flap/domainInfo.txt)
export DOMAIN_NAME=$(echo $DOMAIN_INFO | cut -d ' ' -f1)

# Read passwords from files
export ADMIN_PWD=$(readPwd /var/lib/flap/adminPwd.txt)
export SOGO_DB_PWD=$(readPwd /var/lib/flap/sogoDbPwd.txt)
export NEXTCLOUD_DB_PWD=$(readPwd /var/lib/flap/nextcloudDbPwd.txt)

case $CMD in
    generate)
        # Nginx
        echo "Generating configurations for Nginx"
        envsubst < $FLAP_DIR/nginx/config/nginx.template.conf > $FLAP_DIR/nginx/config/nginx.conf
        envsubst < $FLAP_DIR/nginx/config/conf.d/flap.template.conf > $FLAP_DIR/nginx/config/conf.d/flap.conf
        envsubst < $FLAP_DIR/nginx/config/conf.d/sogo.template.conf > $FLAP_DIR/nginx/config/conf.d/sogo.conf
        envsubst < $FLAP_DIR/nginx/config/conf.d/nextcloud.template.conf > $FLAP_DIR/nginx/config/conf.d/nextcloud.conf
        # PostgreSQL
        echo "Generating configurations for PostgreSQL"
        envsubst < $FLAP_DIR/postgres/scripts/setup.template.sql > $FLAP_DIR/postgres/scripts/setup.sql
        envsubst < $FLAP_DIR/postgres/postgres.template.env > $FLAP_DIR/postgres/postgres.env
        # LDAP
        echo "Generating configurations for LDAP"
        envsubst < $FLAP_DIR/ldap/ldap.template.env > $FLAP_DIR/ldap/ldap.env
        # FLAP core
        echo "Generating configurations for FLAP core"
        envsubst < $FLAP_DIR/core/core.template.env > $FLAP_DIR/core/core.env
        # Nextcloud
        echo "Generating configurations for nextcloud"
        envsubst < $FLAP_DIR/nextcloud/nextcloud.template.env > $FLAP_DIR/nextcloud/nextcloud.env
        # SOGo
        echo "Generating configurations for SOGo"
        envsubst < $FLAP_DIR/sogo/config/sogo.template.conf > $FLAP_DIR/sogo/config/sogo.conf
        envsubst < $FLAP_DIR/sogo/sogo.template.env > $FLAP_DIR/sogo/sogo.env
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
