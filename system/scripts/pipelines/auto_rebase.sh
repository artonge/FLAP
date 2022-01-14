#!/bin/bash

set -eu

opened_merge_requests=$(curl -H "Authorization: Bearer $CI_JOB_TOKEN" https://gitlab.com/api/v4/projects/"$CI_PROJECT_ID"/merge_requests?state=opened)

for iid in $(echo "$opened_merge_requests" | jq '.[] | .iid')
do
	curl -X PUT -H "Authorization: Bearer $CI_JOB_TOKEN" https://gitlab.com/api/v4/projects/"$CI_PROJECT_ID"/merge_requests/"$iid"/rebase
done
