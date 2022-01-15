#!/bin/bash

set -euo pipefail

EXIT=0

PORT=$RANDOM

{
    echo "      - Opening port $PORT"
    {
        flapctl ports open $PORT > /dev/null
    } || {
        echo "     ❌ 'flapctl ports open $PORT' failed to open the port."
        EXIT=1
    }
}

{
    echo "      - Reopening port $PORT"
    {
        flapctl ports open $PORT > /dev/null
    } || {
        echo "     ❌ 'flapctl ports open $PORT' failed to reopen the port."
        EXIT=1
    }
}

{
    echo "      - Listing port mappings"
    {
        flapctl ports list | grep $PORT > /dev/null
    } || {
        echo "     ❌ 'flapctl ports list' failed to list the open port $PORT."
        EXIT=1
    }
}

{
    echo "      - Closing port $PORT"
    {
        flapctl ports close $PORT > /dev/null
    } || {
        echo "     ❌ 'flapctl ports close $PORT' failed to close the port."
        EXIT=1
    }
}

{
    echo "      - Reclosing port $PORT"
    {
        flapctl ports close $PORT > /dev/null
    } || {
        echo "     ❌ 'flapctl ports close $PORT' failed to reclose the port."
        EXIT=1
    }
}

exit $EXIT