#!/bin/sh

set -e

# Download Debian armmp kernel package and build files suitable
# for a LAVA pipeline job.

# The dtb needs to be copied manually, depending on the board.
# Needs an apt source for arch=armhf and the tree package installed.
# Jessie or newer only.

DIR=`mktemp -d`
cd ${DIR}
PKG=`apt show linux-image-armmp 2>/dev/null|grep Depends|cut -d' ' -f2`
VER=`apt list ${PKG} 2>/dev/null|grep -v Listing|cut -d' ' -f2`
sudo apt -dy install $PKG
# linux-image-3.16.0-4-armmp_3.16.7-ckt7-1_armhf.deb
dpkg -X /var/cache/apt/archives/${PKG}_${VER}_armhf.deb .
mkdir lava
find lib -type d -o -type f -name modules.\*  -o -type f -name \*.ko \
 \( -path \*/kernel/lib/\* -o  -path \*/kernel/crypto/\* \
 -o  -path \*/kernel/fs/mbcache.ko -o  -path \*/kernel/fs/ext\* \
 -o  -path \*/kernel/fs/jbd\* -o  -path \*/kernel/drivers/net/\* \
 -o -path \*/kernel/drivers/ata/\* -o  -path \*/kernel/drivers/scsi/\* \
 -o -path \*/kernel/drivers/md/\* \) -print0 | tar cfz lava/modules.tgz --null -T -
cp ./boot/vmlinuz-*-armmp lava/
sudo rm -rf ./boot
sudo rm -rf ./usr/share
sudo rm -rf ./lib
tree ${DIR}
