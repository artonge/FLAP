#!/bin/bash

set -euo pipefail

EXIT=0

{
    echo "      - Getting internal IP"

    # Test
    {
        IP=$(flapctl ip internal) &&
        echo "$IP" | grep --quiet -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$"
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
        echo "$IP" | grep --quiet -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    } || {
        echo "     ❌ 'flapctl ip external' failed to return ip address: '$IP'."
        EXIT=1
    }
}

exit $EXIT
