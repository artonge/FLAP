#!/bin/bash

set -u

CMD=${1:-}
ARGS=($@)
ARGS=${ARGS[@]:1}


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

# Export env var.
export PRIMARY_DOMAIN_NAME=$($FLAP_DIR/system/cli/lib/tls/show_primary_domain.sh)
export DOMAIN_NAMES=$($FLAP_DIR/system/cli/lib/tls/list_domains.sh | grep OK | cut -d ' ' -f1 | paste -sd " " -)
export SUBDOMAINS="auth files sogo"

# Read passwords from files
export ADMIN_PWD=$(readPwd $FLAP_DATA/system/data/adminPwd.txt)
export SOGO_DB_PWD=$(readPwd $FLAP_DATA/system/data/sogoDbPwd.txt)
export NEXTCLOUD_DB_PWD=$(readPwd $FLAP_DATA/system/data/nextcloudDbPwd.txt)


if [ -f $FLAP_DIR/system/cli/cmd/$CMD.sh ]
then
    # Highlight FLAP's logs with grep.
    let "i=29 + $(pstree -ls $$ | grep -o '\<manager\>' | wc -l)"
    OLD_GREP_COLOR=${GREP_COLOR:-"1;$i"}
    export GREP_COLOR="1;$i"

    # --line-buffered allow grep line by line output instead of grep using a larger buffer.
    # --color=always allow for the color not to be overrided.
    $FLAP_DIR/system/cli/cmd/$CMD.sh $ARGS &> /dev/stdout | grep --line-buffered --color=always -E "^(\| )*\* \[.+\].+|$"

    # Restore GREP_COLOR.
    export GREP_COLOR=$OLD_GREP_COLOR
else
    $FLAP_DIR/system/cli/cmd/help.sh $ARGS
fi

# Display "ERROR" when the cmd returned an error.
if [ $? != 0 ]
then
    echo "* [manager] ERROR"
    exit 1
fi
