#!/bin/bash

set -e

EXIT=0

{
    echo "      - Getting internal IP"

    # Test
    {
        IP=$(manager ip internal) &&
        echo $IP | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$" > /dev/null
    } || {
        echo "     ❌ 'manager ip internal' failed to return ip address: '$IP'."
        EXIT=1
    }
}

{
    echo "      - Getting external IP"

    # Test
    {
        IP=$(manager ip external) &&
        echo $IP | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$" > /dev/null
    } || {
        echo "     ❌ 'manager ip external' failed to return ip address: '$IP'."
        EXIT=1
    }
}

exit $EXIT