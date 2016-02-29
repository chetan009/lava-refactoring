#!/bin/sh

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
# 
#

set -e
set -x

rm -rf jessie-armhf/
debootstrap --variant=minbase --foreign --arch=armhf jessie jessie-armhf http://mirror.bytemark.co.uk/debian
echo deb http://mirror.bytemark.co.uk/debian jessie main > jessie-armhf/etc/apt/sources.list
echo jessie > jessie-armhf/etc/hostname
cp /usr/bin/qemu-arm-static jessie-armhf/usr/bin/
chroot jessie-armhf/ debootstrap/debootstrap --second-stage
chroot jessie-armhf/ passwd root -d
chroot jessie-armhf/ apt -q update
chroot jessie-armhf/ apt -y -q install linux-image-armmp
mv jessie-armhf/boot/* .
mv jessie-armhf/usr/lib/linux-image-* .
mv linux-image-* dtbs
tar -C jessie-armhf/ -czf modules.tar.gz ./lib/modules/
rm -rf jessie-armhf/lib/modules/
tar -C jessie-armhf/ -czf jessie-armhf-nfs.tar.gz .
rm -rf jessie-armhf/
ln -s initrd.img-*  initramfs.cpio.gz
ln -s vmlinuz-* vmlinuz
md5sum initramfs.cpio.gz > initramfs.cpio.gz.md5sum.txt
sha256sum initramfs.cpio.gz > initramfs.cpio.gz.sha256sum.txt
md5sum vmlinuz > vmlinuz.md5sum.txt
sha256sum vmlinuz > vmlinuz.sha256sum.txt
md5sum jessie-armhf-nfs.tar.gz > jessie-armhf-nfs.tar.gz.md5sum.txt
sha256sum jessie-armhf-nfs.tar.gz > jessie-armhf-nfs.tar.gz.sha256sum.txt
md5sum modules.tar.gz > modules.tar.gz.md5sum.txt
sha256sum modules.tar.gz > modules.tar.gz.sha256sum.txt
md5sum dtbs/* > dtbs.md5sum.txt
sha256sum dtbs/* > dtbs.sha256sum.txt
