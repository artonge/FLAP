#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	setup)
		flapctl disks single
		flapctl disks raid1
		;;
	single)
		if [ "${FLAG_DISK_MODE_SINGLE:-}" != "true" ]
		then
			exit 0
		fi

		if findmnt "$FLAP_DATA"
		then
			echo "* [disk] Single disk already mounted, exiting."
			exit 0
		fi

		mkdir --parents "$FLAP_DATA/system/data"

		echo '* [disk] Checking disk status.'

		disk=$(yq --raw-output .disks[0] "$FLAP_DIR/flap_init_config.yml")
		disk=${disk:-"/dev/sda"}

		mount "$disk" "$FLAP_DATA"
		if [ -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			echo '* [setup] Disk is a FLAP install, exiting.'
			exit 0
		else
			echo '* [setup] Disk is not a FLAP install.'
			umount "$FLAP_DATA"
		fi

		echo '* [setup] Setting up disk for FLAP.'
		mkfs -t ext4 "$disk"
		mount "$disk" "$FLAP_DATA"
		mkdir --parents "$FLAP_DATA/system/data"
		echo "$disk" > "$FLAP_DATA/system/data/disk.txt"

		# Make the disk mount on boot.
		echo "$disk $FLAP_DATA ext4 defaults,nofail,discard 0 0" | tee -a /etc/fstab

		flapctl setup flapenv
	;;
	raid1)
		if [ "${FLAG_DISK_MODE_RAID1:-}" != "true" ]
		then
			exit 0
		fi

		if [ -e /dev/md0 ]
		then
			echo "* [disks] RAID array is already created."
			exit 0
		fi

		# Get the disks filenames from the usb ports.
		disk_path1=$(yq --raw-output .disks_path[0] "$FLAP_DIR/flap_init_config.yml")
		disk1=$(ls "$disk_path1")

		disk_path2=$(yq --raw-output .disks_path[1] "$FLAP_DIR/flap_init_config.yml")
		disk2=$(ls "$disk_path2")

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
		echo "/dev/$disk1 -d sat -m $ADMIN_EMAIL -a -o on -S on -s (S/../.././02|L/../../6/03)" > /etc/smartd.conf
		echo "/dev/$disk2 -d sat -m $ADMIN_EMAIL -a -o on -S on -s (S/../.././02|L/../../6/03)" >> /etc/smartd.conf

		# Activate mdadm monitoring:
		# mdadm --monitor --daemonise --test --scan
		# The commade is here for reference, but it is not usefull.
		# Mdadm monitoring is on by default. The warning are sent to the mail address specified in /etc/aliases.
		# You can test the reception of the mail with the following command:
		# mdadm --monitor --scan --test -1

		flapctl setup flapenv
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
	setup | | Setup disks.
	check | | Check that the RAID array is OK." | column -t -s "|"
		;;
esac
