#!/bin/bash

set -eu

EXIT=0

PORT=$RANDOM

{
    echo "      - Opening port $PORT"
    {
        manager ports open $PORT > /dev/null
    } || {
        echo "     ❌ 'manager ports open $PORT' failed to open the port."
        EXIT=1
    }
}

{
    echo "      - Reopening port $PORT"
    {
        manager ports open $PORT > /dev/null
    } || {
        echo "     ❌ 'manager ports open $PORT' failed to reopen the port."
        EXIT=1
    }
}

{
    echo "      - Listing port mappings"
    {
        manager ports list | grep $PORT > /dev/null
    } || {
        echo "     ❌ 'manager ports list' failed to list the open port $PORT."
        EXIT=1
    }
}

{
    echo "      - Closing port $PORT"
    {
        manager ports close $PORT > /dev/null
    } || {
        echo "     ❌ 'manager ports close $PORT' failed to close the port."
        EXIT=1
    }
}

{
    echo "      - Reclosing port $PORT"
    {
        manager ports close $PORT > /dev/null
    } || {
        echo "     ❌ 'manager ports close $PORT' failed to reclose the port."
        EXIT=1
    }
}

exit $EXIT