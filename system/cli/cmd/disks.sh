#!/bin/bash

set -e

CMD=$1

function format_disk {
    disk=$1
    name=$2
    mountpoint=$3

    # If the main disk is mounted, unmount it.
    if [ "$(manager disks list | grep ${disk}1 | grep $mountpoint | cat)" != "" ]
    then
        umount $mountpoint
    fi

    # Delete all partitions from the disk.
    wipefs --all --force /dev/$disk

    # Create a GPT partitions table.
    parted --script /dev/$disk mklabel gpt

    # Create a partition.
    parted --script /dev/$disk mkpart $name ext4 0% 100%

    # Setup an ext4 filesystem on the partition.
    yes | mkfs.ext4 /dev/${disk}1

    # Mark the disk as a FLAP disk.
    mkdir -p $mountpoint
    mount /dev/${disk}1 $mountpoint
    touch $mountpoint/is_flap.txt

    # Add the disk to fstab.
    register_in_fstab ${disk}1 $mountpoint
}

function register_in_fstab {
    partition=$1
    mountpoint=$2

    # Get the sdb UUID
    main_uuid=$(manager disks list | grep $partition | cut -d ' ' -f2)
    # Load fstab content without any line that match the UUID
    fstab=$(cat /etc/fstab | grep -v "$mountpoint ext4")
    echo "$fstab" > /etc/fstab
    # Add a new line for UUID and dir name
    echo "UUID='$main_uuid' $mountpoint ext4 defaults,nofail 0 0" >> /etc/fstab
}

case $CMD in
    setup)
        # MAIN DISK
        # If the main disk is not plugged, send a warning, stop FLAP and exit now.
        if [ "$(manager disks list | grep disk | grep sda | cat)" == "" ]
        then
            # TODO: Send warning
            # Go to FLAP_DIR for docker-compose
            cd $FLAP_DIR
            docker-compose down
            exit 1
        fi

        # If the main disk is not mounted, mount it.
        if [ "$(manager disks list | grep sda1 | grep '/flap' | cat)" == "" ]
        then
            mount /etc/sda1 /flap
        fi

        # If the main disk is not formated for FLAP, format it and try to restore the data from the backup.
        if [ ! -f /flap/is_flap.txt ]
        then
            manager disks format sda
            manager backup restore
        fi


        # BACKUP DISK
        # If the backup disk is not plugged, send a warning and exit now.
        if [ "$(manager disks list | grep disk | grep sdb | cat)" != "" ]
        then
            # TODO: Send warning
            exit 1
        fi

        # If the backup disk is not mounted, mount it.
        if [ "$(manager disks list | grep part | grep sdb1 | grep '/flap_backup' | cat)" != "" ]
        then
            mount /etc/sdb /flap_backup
        fi

        # If the backup disk is not formated for FLAP, format it and create a backup.
        if [ ! -f /flap_backup/is_flap.txt ]
        then
            manager disks format sdb
            manager backup
        fi
        ;;
    format)
        case $2 in
            sda) format_disk sda flap_main /flap ;;
            sdb) format_disk sdb flap_backup /flap_backup ;;
            *) echo "FLAP don't want to format that disk." ;;
        esac
        ;;
    list)
        lsblk --include 8 --noheadings --list --output NAME,PARTUUID,TYPE,MOUNTPOINT
        ;;
    summarize)
        echo "disks | [open, close, list, help] | Manipulate usb disks."
        ;;
    help|*)
        printf "
disks | Manipulate usb disks.
Commands:
    setup | | Setup disks if necessary.
    format | | Format a disk to format that FLAP likes.
    list | | List available disks." | column -t -s "|"
        ;;
esac
