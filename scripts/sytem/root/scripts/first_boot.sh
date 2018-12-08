#!/bin/bash
BOOT=/etc/rc.local
BOOTDEVICE=`ls -l /dev/disk/by-uuid/ | grep 96C3-9298 | awk '{print $11}' | sed "s/\.\.\/\.\.\///" | sed "s/p1//"`

# https://raspberrypi.stackexchange.com/questions/499/how-can-i-resize-my-root-partition/501#501?newreg=52ef2c5dea084157b5cb420f87aef9c8
function do_resize
{
	# this takes in consideration /dev/mmcblk1p2 as the rootfs!
	rsflog=/root/resize-$DATE-log.txt
	echo "Saving the log to $rsflog"
	sleep 4

	p2_start=`fdisk -l /dev/$BOOTDEVICE | grep ${BOOTDEVICE}p2 | awk '{print $2}'`
	p2_end=$(((`fdisk -l /dev/$BOOTDEVICE | head -n1 | grep -i bytes | awk '{print $5}'`/512)-20))
	echo $p2_end

	fdisk /dev/$BOOTDEVICE <<EOF &>> $rsflog
p
d
2
n
p
2
$p2_start
$p2_end
p
w
EOF
	sync && sync
	sed -i "s/\/root\/scripts\/first-boot/\/root\/scripts\/resize/" "$BOOT"
	echo > /etc/udev/rules.d/70-persistent-net.rules
}

fix_ssh()
{
	rm -rf /etc/ssh/ssh_host_*_key
	dpkg-reconfigure openssh-server
}

function remove_start
{
        sed -i "s/\/root\/scripts\/first-boot//" "$BOOT"
}

function install_flap()
{



}

do_resize
remove_start
fix_ssh
systemctl enable systemd-timesyncd.service
sync
reboot
