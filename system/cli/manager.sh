#!/bin/bash

set -e

CMD=$1
ARGS=($@)
ARGS=${ARGS[@]:1}

if [ -f $FLAP_DIR/system/cli/cmd/$CMD.sh ]
then
    $FLAP_DIR/system/cli/cmd/$CMD.sh $ARGS
else
    $FLAP_DIR/system/cli/cmd/help.sh $ARGS
fi