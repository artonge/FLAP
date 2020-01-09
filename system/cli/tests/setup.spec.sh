#!/bin/bash

set -eu

EXIT=0

# {
#     echo "      - Create main cron file"

#     # Save user's cron
#     user_cron=$(crontab -l | true) > /dev/null

#     # Delete crontab
#     echo "" | crontab -

#     {
#         # Ensure crontab is empty
#         crontab -l | grep -v -E ".+" > /dev/null &&
#         # Generate crontab
#         flapctl setup cron &&
#         # Ensure crontab is filled
#         crontab -l | grep -E ".+" > /dev/null
#     } || {
#         echo "     ❌ 'flapctl setup' failed to create the main cron file."
#         EXIT=1
#     }

#     # Restore user's cron
#     echo $user_cron | crontab -
# }

exit $EXIT
