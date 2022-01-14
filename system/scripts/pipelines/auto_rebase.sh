#!/bin/bash

set -eu

for iid in $(curl --silent https://gitlab.com/api/v4/projects/"$CI_PROJECT_ID"/merge_requests?state=opened | jq '.[] | .iid')
do
	curl -X PUT -H "Authorization: Bearer $CI_JOB_TOKEN" https://gitlab.com/api/v4/projects/"$CI_PROJECT_ID"/merge_requests/"$iid"/rebase
done
