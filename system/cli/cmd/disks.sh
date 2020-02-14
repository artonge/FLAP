#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	setup)
		# Prevent some operations during CI and DEV.
		if [ "${CI:-false}" == "true" ] || [ "${DEV:-false}" == "true" ]
		then
			echo "* [disks] Skip RAID array creation during CI or DEV."
			exit 0
		fi

		# Don't build the array if it is already created.
		if [ -e /dev/md0 ]
		then
			echo "* [disks] RAID array is allready created."
			exit 0
		fi

		# Get the disks filenames from the usb ports.
		# TODO: need better disk name guessing
		disk1="$(ls "/sys/bus/usb/drivers/usb/4-1.1/4-1.1\:1.0/host0/target0\:0\:0/0\:0\:0\:0/block")"
		disk2="$(ls "/sys/bus/usb/drivers/usb/4-1.2/4-1.2\:1.0/host1/target1\:0\:0/1\:0\:0\:0/block")"

		echo "* [disks] Creating RAID array with $disk1 and $disk2."

		mdadm --create --run /dev/md0 --level=1 --raid-devices=2 "/dev/$disk1" "/dev/$disk2"
		mkfs.ext4 -F /dev/md0
		mkdir --parents "$FLAP_DATA"
		mount /dev/md0 "$FLAP_DATA"

		# Check that the RAID array is correctly mounted.
		df | grep md0

		# Save the configuration.
		mdadm --detail --scan | tee --append /etc/mdadm/mdadm.conf

		# Make the RAID array mount on boot.
		update-initramfs -u
		echo "/dev/md0 $FLAP_DATA ext4 defaults,nofail,discard 0 0" | tee -a /etc/fstab
		;;
	check)
		mdadm --detail --test /dev/md0
		;;
	summarize)
		echo "disks | [setup, check] | Manipulate usb disks."
		;;
	help|*)
		echo "
$(flapctl disks summarize)
Commands:
	setup | | Setup RAID 1 array.
	check | | Check that the RAID array is OK." | column -t -s "|"
		;;
esac
