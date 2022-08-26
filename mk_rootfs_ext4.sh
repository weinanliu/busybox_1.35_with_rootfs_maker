#!/bin/bash
set -x

dd if=/dev/zero of=rootfs.busybox.ext4 bs=1024 count=4096 #4096kb
mkfs.ext4 rootfs.busybox.ext4

sudo rm -rf ./rootfs_tmp
mkdir rootfs_tmp

sudo mount -o loop rootfs.busybox.ext4 ./rootfs_tmp

sudo cp -r _install/* ./rootfs_tmp

sudo mkdir rootfs_tmp/root
sudo mkdir rootfs_tmp/proc
sudo mkdir rootfs_tmp/tmp
sudo mkdir rootfs_tmp/dev
sudo mkdir rootfs_tmp/sys
sudo mkdir rootfs_tmp/etc

cat <<EOF | sudo tee rootfs_tmp/etc/fstab
proc  /proc proc  defaults  0 0
tmpfs /tmp  tmpfs defaults  0 0
tmpfs /dev  tmpfs defaults  0 0
sysfs /sys  sysfs defaults  0 0
EOF

cat <<EOF | sudo tee rootfs_tmp/etc/passwd
root:x:0:0:root:/root:/bin/sh
EOF

cat <<EOF | sudo tee rootfs_tmp/etc/group
root:x:0:
EOF

sudo cp examples/inittab rootfs_tmp/etc

cat <<EOF | sudo tee rootfs_tmp/etc/profile
export PS1='[\u@\h \W]\$ '
EOF

sudo mkdir rootfs_tmp/etc/init.d
cat <<EOF | sudo tee rootfs_tmp/etc/init.d/rcS
mount -a
mkdir /dev/pts
mount -t devpts devpts /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
/bin/sh
EOF
sudo chmod 777 rootfs_tmp/etc/init.d/rcS

sudo umount ./rootfs_tmp

sudo rm -rf rootfs_tmp

