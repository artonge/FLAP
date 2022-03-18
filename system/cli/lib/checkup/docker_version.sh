#!/bin/bash

set -euo pipefail

exit_code=0

docker_releases=$(curl --silent https://api.github.com/repos/moby/moby/releases)
docker_latest_release=$(echo "$docker_releases" | jq --raw-output '.[0]')
last_upstream_docker_version=$(echo "$docker_latest_release" | jq --raw-output '.tag_name')
last_upstream_docker_version_date=$(echo "$docker_latest_release" | jq --raw-output '.published_at')

local_docker_version=v$(docker --version | cut -d ' ' -f3 | sed s/,//)
local_docker_version_date=$(echo "$docker_releases" | jq --raw-output --arg version "$local_docker_version" '.[] | select(.tag_name == $version).published_at')

one_year_before_last_release=$(date --utc +"%Y-%m-%d" --date "$last_upstream_docker_version_date-1year")

if [[ $local_docker_version_date < $one_year_before_last_release ]]
then
	echo "	- You docker version is old"
	echo "		- local: $local_docker_version ($local_docker_version_date)"
	echo "		- latest: $last_upstream_docker_version ($last_upstream_docker_version_date)"
	exit_code=1
fi

exit $exit_code