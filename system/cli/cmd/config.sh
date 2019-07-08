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

export DOMAIN_NAME=$(manager tls primary)
export DOMAIN_NAMES=$(manager tls list | grep OK | cut -d ' ' -f1 | paste -sd " " -)
export ALL_DOMAIN_NAMES=$(manager tls list_all | grep OK | cut -d ' ' -f1 | paste -sd " " -)
export DOMAIN_NAMES_SOGO=$(manager tls list_all | grep -E "^sogo\." | grep OK | cut -d ' ' -f1 | paste -sd " " -)
export DOMAIN_NAMES_FILES=$(manager tls list_all | grep -E "^files\." | grep OK | cut -d ' ' -f1 | paste -sd " " -)

# Read passwords from files
export ADMIN_PWD=$(readPwd $FLAP_DATA/system/data/adminPwd.txt)
export SOGO_DB_PWD=$(readPwd $FLAP_DATA/system/data/sogoDbPwd.txt)
export NEXTCLOUD_DB_PWD=$(readPwd $FLAP_DATA/system/data/nextcloudDbPwd.txt)

case $CMD in
    generate)
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

            envsubst '${DOMAIN_NAME} ${DOMAIN_NAMES} ${DOMAIN_NAMES_SOGO} ${DOMAIN_NAMES_FILES} ${ALL_DOMAIN_NAMES} ${ADMIN_PWD} ${SOGO_DB_PWD} ${NEXTCLOUD_DB_PWD}' < ${FLAP_DIR}/$dir/$name.template.$ext > ${FLAP_DIR}/$dir/$name.$ext
        done
       ;;
    show)
        echo "DOMAIN_NAME=$DOMAIN_NAME"
        echo "DOMAIN_NAMES=$DOMAIN_NAMES"
        echo "DOMAIN_NAMES_SOGO=$DOMAIN_NAMES_SOGO"
        echo "DOMAIN_NAMES_FILES=$DOMAIN_NAMES_FILES"
        echo "ALL_DOMAIN_NAMES=$ALL_DOMAIN_NAMES"
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
