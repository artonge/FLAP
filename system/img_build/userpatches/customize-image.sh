#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

set -euo pipefail


# Avahi and mysql/mariadb needs to do some stuff which conflicts with
# the "change the root password asap" so we disable it.
# We also do not need to change the password because password login is disabled for ssh.
chage -d 99999999 root

# Run the flap install script.
/tmp/overlay/install_flap.sh "$VERSION"

echo "Saving the docker images in the final disk image."
mkdir -p /var/lib/flap/images
cp /tmp/overlay/*.tar.gz /var/lib/flap/images

# Prevent user creation on first boot.
rm /root/.not_logged_in_yet

apt clean
