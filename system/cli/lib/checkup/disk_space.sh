#!/bin/bash

set -eu

exit_code=0

function checkSpace() {
	path="$1"
	path_exit_code=0

	device=$(df -h --output=source,size,used,avail,pcent,file,target "$path" | grep "$path"):

	source=$(echo "$device" | awk '{print $1}')
	size=$(echo "$device" | awk '{print $2}')
	used=$(echo "$device" | awk '{print $3}')
	avail=$(echo "$device" | awk '{print $4}' | cut -d 'G' -f1)
	pcent=$(echo "$device" | awk '{print $5}' | cut -d '%' -f1)

	if [[ "$pcent" -gt "95" ]]
	then
		echo "- Server free storage is less than 5% for $path."
		path_exit_code=1
	fi

	if [[ "$avail" -lt "10" ]]
	then
		echo "- Server free storage is less than 10 Go for $path."
		path_exit_code=1
	fi

	if [ "$path_exit_code" == 1 ]
	then
		exit_code=1
		echo "	- Source: $source"
		echo "	- Size: $size"
		echo "	- Used: $used"
		echo "	- Avail: ${avail}G"
		echo "	- Percent: ${pcent}%"
	fi
}

checkSpace "$FLAP_DATA"
checkSpace "$FLAP_DIR"

exit $exit_code