#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    generate)
        # Generate services templates
        manager config generate_templates

        # Generate lemonLDAP configuration file.
        manager config generate_lemon

        # Generate nginx configurations
        manager config generate_nginx
    ;;
    generate_templates)
        echo '* [config] Generate template final files from the current config'

        # Go to FLAP_DIR to have access to template files.
        cd $FLAP_DIR

        # Transform each files matching *.template.*
        for template in $(find -name "*.template.*")
        do
            dir=$(dirname $template) # Get template's directory
            name=$(basename $template) # Get template's name (without the directory)
            ext="${name##*.}"
            name="${name%.*}" # Remove extension
            name="${name%.*}" # Remove ".template"

            echo $dir/$name.$ext

            envsubst '${PRIMARY_DOMAIN_NAME} ${DOMAIN_NAMES} ${DOMAIN_NAMES_SOGO} ${DOMAIN_NAMES_FILES} ${ADMIN_PWD} ${SOGO_DB_PWD} ${NEXTCLOUD_DB_PWD}' < ${FLAP_DIR}/$dir/$name.template.$ext > ${FLAP_DIR}/$dir/$name.$ext
        done
       ;;
    generate_lemon)
        echo '* [config] Generate lemonLDAP configuration file.'

        # Alter lemonLDAP config using jq.

        echo "* [config] Set SAML keys."
        config=$(cat $FLAP_DIR/lemon/config/lmConf-1.json)
        echo $config | \
            jq --arg privateKey "`cat $FLAP_DATA/lemon/saml/private_key.pem`" '.samlServicePrivateKeySig=$privateKey' | \
            jq --arg publicKey  "`cat $FLAP_DATA/lemon/saml/cert.pem`" '.samlServicePublicKeySig=$publicKey' \
        > $FLAP_DIR/lemon/config/lmConf-1.json

        echo "* [config] Add vhosts and SAML metadata to the lemonLDAP config."
        for service in $(ls --directory $FLAP_DIR/*/)
        do
            service=$(basename $service)

            for domain in $DOMAIN_NAMES
            do
                # Check if lemon config exists for the service.
                if [ -f $FLAP_DIR/$service/config/lemon.jq ]
                then
                    echo "$service - $domain"
                    vhostType=$([ "$PRIMARY_DOMAIN_NAME" ==  "$domain" ] && echo "Main" || echo "CDA")
                    vhostType='CDA'
                    [ -f $FLAP_DATA/$service/saml/metadata_$domain.xml ] && metadata=$(cat $FLAP_DATA/$service/saml/metadata_$domain.xml)
                    config=$(cat $FLAP_DIR/lemon/config/lmConf-1.json)
                    # Add a vhost for each domains.
                    jq \
                        --null-input \
                        --arg domain "$domain" \
                        --arg vhostType "$vhostType" \
                        --arg samlMetadata "${metadata:-}" \
                        --from-file $FLAP_DIR/$service/config/lemon.jq | \
                    jq \
                        --slurp \
                        --argjson config \
                        "$config" '.[0] * $config' \
                    > $FLAP_DIR/lemon/config/lmConf-1.json
                fi
            done
        done
        ;;
    generate_nginx)
        echo '* [config] Generate Nginx configurations files for each domains'

        # Create directory architecture
        mkdir -p $FLAP_DIR/nginx/config/conf.d/domains

        # Reset domains includes files.
        if [ "$PRIMARY_DOMAIN_NAME" == "" ]
        then
            echo "" > $FLAP_DIR/nginx/config/conf.d/domains.conf
        else
            echo "include /etc/nginx/parts.d/tls.inc;" > $FLAP_DIR/nginx/config/conf.d/domains.conf
        fi

        # Clean old domains service config files
        rm -rf $FLAP_DIR/nginx/config/conf.d/domains/*

        # Generate conf for each domains
        for domain in $DOMAIN_NAMES
        do
            echo $domain
            echo "include /etc/nginx/conf.d/domains/$domain/*.conf;" >> $FLAP_DIR/nginx/config/conf.d/domains.conf
            mkdir -p $FLAP_DIR/nginx/config/conf.d/domains/$domain # Create domain's conf directory

            for service_path in $(ls --directory $FLAP_DIR/*/) # Generate conf for each services
            do
                if [ -f $service_path/nginx.conf ]
                then
                    service=$(basename $service_path) # Get the service name
                    echo "  - $service"
                    export DOMAIN_NAME=$domain
                    envsubst '${DOMAIN_NAME}' < $service_path/nginx.conf > $FLAP_DIR/nginx/config/conf.d/domains/$domain/$service.conf
                fi
            done
        done
       ;;
    show)
        echo "PRIMARY_DOMAIN_NAME=$PRIMARY_DOMAIN_NAME"
        echo "DOMAIN_NAMES=$DOMAIN_NAMES"
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
    show | | Show the current config variables." | column -t -s "|"
        ;;
esac
