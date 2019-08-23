#!/bin/bash

set -eu

CMD=${1:-}

# Read password from file.
# If the file does not exists, create it and generate a password.
readPwd() {
    mkdir -p $FLAP_DATA/system/data

    if [ ! -f $1 ]
    then
        openssl rand --hex 32 > $1
    fi

    cat $1
}

export PRIMARY_DOMAIN_NAME=$(manager tls primary)
export DOMAIN_NAMES=$(manager tls list | grep OK | cut -d ' ' -f1 | paste -sd " " -)

# Read passwords from files
export ADMIN_PWD=$(readPwd $FLAP_DATA/system/data/adminPwd.txt)
export SOGO_DB_PWD=$(readPwd $FLAP_DATA/system/data/sogoDbPwd.txt)
export NEXTCLOUD_DB_PWD=$(readPwd $FLAP_DATA/system/data/nextcloudDbPwd.txt)

case $CMD in
    generate)
        # Generate services templates
        manager config generate_templates

        # Generate nginx configurations
        manager config generate_nginx
    ;;
    generate_templates)
        echo * Generate template\'s final files from the current config

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

            envsubst '${DOMAIN_NAME} ${DOMAIN_NAMES} ${DOMAIN_NAMES_SOGO} ${DOMAIN_NAMES_FILES} ${ADMIN_PWD} ${SOGO_DB_PWD} ${NEXTCLOUD_DB_PWD}' < ${FLAP_DIR}/$dir/$name.template.$ext > ${FLAP_DIR}/$dir/$name.$ext
        done
       ;;
    generate_nginx)
        echo * Generate Nginx configurations files for each domains

        # Create directory architecture
        mkdir -p $FLAP_DIR/nginx/config/conf.d/domains

        # Clean old domains includes files
        echo "" > $FLAP_DIR/nginx/config/conf.d/domains.conf

        # Clean old domains service config files
        rm -rf $FLAP_DIR/nginx/config/conf.d/domains/*

        # Generate conf for each domains
        DOMAINS=($DOMAIN_NAMES)
        for i in "${!DOMAINS[@]}"
        do
            export DOMAIN_NAME=${DOMAINS[$i]}
            echo $DOMAIN_NAME
            echo "include /etc/nginx/conf.d/domains/$DOMAIN_NAME/*.conf;" >> $FLAP_DIR/nginx/config/conf.d/domains.conf
            mkdir -p $FLAP_DIR/nginx/config/conf.d/domains/$DOMAIN_NAME # Create domain's conf directory

            for service_path in $(ls --directory $FLAP_DIR/*/) # Generate conf for each services
            do
                if [ -f $service_path/nginx.conf ]
                then
                    service=$(basename $service_path) # Get the service name
                    echo "  - $service"
                    envsubst '${DOMAIN_NAME}' < $service_path/nginx.conf > $FLAP_DIR/nginx/config/conf.d/domains/$DOMAIN_NAME/$service.conf
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
