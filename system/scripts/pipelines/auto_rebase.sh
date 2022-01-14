#!/bin/bash

set -eu

gitlab_base_url=https://gitlab.com/api/v4/projects

opened_merge_requests=$(curl -H "Authorization: Bearer $GITLAB_PERSONAL_TOKEN" $gitlab_base_url/"$PROJECT_ID"/merge_requests?state=opened)

for iid in $(echo "$opened_merge_requests" | jq '.[] | .iid'); do
	curl -X PUT -H "Authorization: Bearer $GITLAB_PERSONAL_TOKEN" $gitlab_base_url/"$PROJECT_ID"/merge_requests/"$iid"/rebase
done
