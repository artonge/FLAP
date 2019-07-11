#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
    setup)
        if [ !  -f /dev/md0 ]
        then
            mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sda /dev/sdb
            mkfs.ext4 -F /dev/md0
            mkdir -p /flap
            mount /dev/md0 /flap

            # Check that the RAID array is correctly mounted.
            df -h -x devtmpfs -x tmpfs | grep md0

            # Save the configuration.
            mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

            # Make the RAID array mount on boot.
            update-initramfs -u
            echo '/dev/md0 /mnt/md0 ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
        fi
        ;;
    summarize)
        echo "disks | [setup, help] | Manipulate usb disks."
        ;;
    help|*)
        printf "
disks | Manipulate usb disks.
Commands:
    setup | | Setup RAID 1 array." | column -t -s "|"
        ;;
esac
