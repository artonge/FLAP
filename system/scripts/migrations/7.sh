#!/bin/bash

set -euo pipefail

if [ "${FLAG_NO_RAID_SETUP:-}" == "true" ]
then
	echo "* [disks:FEATURE_FLAG] Skip disks monitoring."
	exit 0
fi

# Get the disks filenames from the usb ports.
# TODO: need better disk name guessing
# shellcheck disable=SC1001
disk1="$(ls /sys/bus/usb/drivers/usb/4-1.1/4-1.1\:1.0/host0/target0\:0\:0/0\:0\:0\:0/block)"
# shellcheck disable=SC1001
disk2="$(ls /sys/bus/usb/drivers/usb/4-1.2/4-1.2\:1.0/host1/target1\:0\:0/1\:0\:0\:0/block)"

# Activate smartd monitoring for the two disks.
# -m Send mail to the provided email address.
# -a Monitor all attributes.
# -o Enable automatic online data collection.
# -s Automatic Attribute autosave.
# -S (../..) Start a short self-test every day between 2-3am, and a long self test Saturdays between 3-4am.
echo "/dev/$disk1 -d sat -m louis@chmn.me -a -o on -S on -s (S/../.././02|L/../../6/03)" > /etc/smartd.conf
echo "/dev/$disk2 -d sat -m louis@chmn.me -a -o on -S on -s (S/../.././02|L/../../6/03)" >> /etc/smartd.conf
