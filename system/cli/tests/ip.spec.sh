#!/bin/bash

set -eu

EXIT=0

{
    echo "      - Getting internal IP"

    # Test
    {
        IP=$(flapctl ip internal) &&
        echo "$IP" | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$" > /dev/null
    } || {
        echo "     ❌ 'flapctl ip internal' failed to return ip address: '$IP'."
        EXIT=1
    }
}

{
    echo "      - Getting external IP"

    # Test
    {
        IP=$(flapctl ip external) &&
        echo "$IP" | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$" > /dev/null
    } || {
        echo "     ❌ 'flapctl ip external' failed to return ip address: '$IP'."
        EXIT=1
    }
}

exit $EXIT
