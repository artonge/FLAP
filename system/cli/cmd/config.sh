#!/bin/bash

set -e

CMD=$1

# Read password from file.
# If the file does not exists, create it and generate a password.
readPwd() {
    mkdir -p $FLAP_DATA

    if [ ! -f $1 ]
    then
        openssl rand --hex 32 > $1
    fi

    cat $1
}

# Create default domainInfo.txt if it is missing
if [ ! -f $FLAP_DATA/domainInfo.txt ]
then
    mkdir -p $FLAP_DATA
    echo "flap.localhost localhost _" > $FLAP_DATA/domainInfo.txt
fi

DOMAIN_INFO=$(cat $FLAP_DATA/domainInfo.txt)
export DOMAIN_NAME=$(echo $DOMAIN_INFO | cut -d ' ' -f1)

# Read passwords from files
export ADMIN_PWD=$(readPwd $FLAP_DATA/adminPwd.txt)
export SOGO_DB_PWD=$(readPwd $FLAP_DATA/sogoDbPwd.txt)
export NEXTCLOUD_DB_PWD=$(readPwd $FLAP_DATA/nextcloudDbPwd.txt)

case $CMD in
    generate)
        for template in $(find -name "*.template.*")
        do
            dir=$(dirname $template)
            name=$(basename $template)
            ext="${name##*.}"
            name="${name%.*}"
            name="${name%.*}"

            echo $dir/$name.$ext

            envsubst '${DOMAIN_NAME} ${ADMIN_PWD} ${SOGO_DB_PWD} ${NEXTCLOUD_DB_PWD}' < ${FLAP_DIR}/$dir/$name.template.$ext > ${FLAP_DIR}/$dir/$name.$ext
        done
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
    show | | Show the current config variables." | column -t -s "|"
        ;;
esac
