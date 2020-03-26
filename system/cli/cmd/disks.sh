#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	setup)
		if [ "${FLAG_NO_RAID_SETUP:-}" == "true" ]
		then
			echo "* [disks:FEATURE_FLAG] Skip RAID array creation."
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
		# shellcheck disable=SC1001
		disk1="$(ls /sys/bus/usb/drivers/usb/4-1.1/4-1.1\:1.0/host0/target0\:0\:0/0\:0\:0\:0/block)"
		# shellcheck disable=SC1001
		disk2="$(ls /sys/bus/usb/drivers/usb/4-1.2/4-1.2\:1.0/host1/target1\:0\:0/1\:0\:0\:0/block)"

		echo "* [disks] Creating RAID array with $disk1 and $disk2."

		# Create RAID array with the first disk.
		mdadm --create --run /dev/md0 --level=1 --raid-devices=1 "/dev/$disk1" --force
		mkfs.ext4 -F /dev/md0
		mkdir --parents "$FLAP_DATA"
		mount /dev/md0 "$FLAP_DATA"

		# Check that the RAID array is correctly mounted.
		findmnt --mountpoint "$FLAP_DATA" --source /dev/md0

		# Add the second disk.
		mdadm /dev/md0 --add "/dev/$disk2"
		mdadm --grow --raid-devices=2 /dev/md0

		# Save the configuration.
		mdadm --detail --scan | tee --append /etc/mdadm/mdadm.conf

		# Make the RAID array mount on boot.
		update-initramfs -u
		echo "/dev/md0 $FLAP_DATA ext4 defaults,nofail,discard 0 0" | tee -a /etc/fstab

		# Activate smartd monitoring for the two disks.
		# -m Send mail to the provided email address.
		# -a Monitor all attributes.
		# -o Enable automatic online data collection.
		# -s Automatic Attribute autosave.
		# -S (../..) Start a short self-test every day between 2-3am, and a long self test Saturdays between 3-4am.
		echo "/dev/$disk1 -d sat -m louis@chmn.me -a -o on -S on -s (S/../.././02|L/../../6/03)" > /etc/smartd.conf
		echo "/dev/$disk2 -d sat -m louis@chmn.me -a -o on -S on -s (S/../.././02|L/../../6/03)" >> /etc/smartd.conf

		# Activate mdadm monitoring:
		# mdadm --monitor --daemonise --test --scan
		# The commade is here for reference, but it is not usefull.
		# Mdadm monitoring is on by default. The warning are sent to the mail address specified in /etc/msmtp.aliases.
		# You can test the reception of the mail with the following command:
		# mdadm --monitor --scan --test -1
		;;
	check)
		# mdadm --detail --test /dev/md0
		# umount /dev/md0
		# fsck -r -C -V /dev/md0
		# mount /dev/md0 /flap
		mapfile -t devices < <(mdadm --detail --brief --verbose /dev/md0 | tail -n 1 | cut -d '=' -f2 | tr ',' ' ')
		echo "${devices[@]}"
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
