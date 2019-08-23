#!/bin/bash

set -eu

CMD=${1:-}
ARGS=($@)
ARGS=${ARGS[@]:1}

if [ -f $FLAP_DIR/system/cli/cmd/$CMD.sh ]
then
    $FLAP_DIR/system/cli/cmd/$CMD.sh $ARGS
else
    $FLAP_DIR/system/cli/cmd/help.sh $ARGS
fi

# Display "ERROR" when the cmd returned an error.
if [ $? != 0 ]
then
    echo ERROR
fi
