#!/bin/bash

set -e

CMD=$1
ARGS=($@)
ARGS=${ARGS[@]:1}

if [ -f ./cmd/$CMD.sh ]
then
    ./cmd/$CMD.sh $ARGS
else
    ./cmd/help.sh $ARGS
fi