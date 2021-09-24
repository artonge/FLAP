#!/bin/bash

set -eu

device=$(df -h --output=source,size,used,avail,pcent,file,target "$FLAP_DATA" | grep "$FLAP_DATA"):

source=$(echo "$device" | awk '{print $1}')
size=$(echo "$device" | awk '{print $2}')
used=$(echo "$device" | awk '{print $3}')
avail=$(echo "$device" | awk '{print $4}' | cut -d 'G' -f1)
pcent=$(echo "$device" | awk '{print $5}' | cut -d '%' -f1)

exit_code=0

if [[ "$pcent" -gt "95" ]]
then
	echo "- Server free storage is less than 5%."
	exit_code=1
fi

if [[ "$avail" -lt "10" ]]
then
	echo "- Server free storage is less than 10 Go."
	exit_code=1
fi

if [ "$exit_code" == 1 ]
then
	echo "	- Source: $source"
	echo "	- Size: $size"
	echo "	- Used: $used"
	echo "	- Avail: ${avail}G"
	echo "	- Percent: ${pcent}%"
fi

exit $exit_code