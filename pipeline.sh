#!/bin/sh

# set -e

# This script runs the dispatcher refactoring code on the command line.
# The output remains confined to local directories due to several reasons:
# 1. This is on the dispatcher, so there is no external apache visibility
# 2. The web frontend has no devices, so cannot run the tests
# 3. The sshfs is sufficiently secure that symlinks result in a directory
#    from which apache cannot serve files, even if the symlink is allowed.
# 4. The sshfs requires sudo su lavaserver -c "command" to use
# 5. After copying to sshfs, the remote web frontend would have to *copy*
#    the files to make those visible.
# 6. One other way would be dummy-host but that's confusing as it merges
#    the new dispatcher output with the old dispatcher output in django.

# Secondary issue, which can be fixed in master, is that the device
# configuration needs some hand-holding currently. The format of the files
# has changed but the current code does not look into paths in /etc/, only
# /usr/lib/python2.7/dist-packages/

START=1416310894

DATE=`date +%s`

ID=`expr $DATE - $START`
OUTPUT="/tmp/kvm-$ID"
mkdir $OUTPUT
sudo touch $OUTPUT/console.log
sudo chmod 666 $OUTPUT/console.log
sudo lava-dispatch --target kvm01 ./local-kvm.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
rsync -az $OUTPUT ..

#panda

if [ -f "/usr/lib/python2.7/dist-packages/lava_dispatcher/pipeline/devices/panda-es-01.conf" ]; then
	DATE=`date +%s`
	ID=`expr $DATE - $START`
	OUTPUT="/tmp/panda-ramdisk-$ID"
	mkdir $OUTPUT
	sudo touch $OUTPUT/console.log
	sudo cp ./panda-es-01.conf /usr/lib/python2.7/dist-packages/lava_dispatcher/pipeline/devices/
	sudo lava-dispatch --target panda-01 ./panda-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
	rsync -az $OUTPUT ..
fi

# bbb

if [ -f "/usr/lib/python2.7/dist-packages/lava_dispatcher/pipeline/devices/bbb-01.conf" ]; then
	DATE=`date +%s`
	ID=`expr $DATE - $START`
	OUTPUT="/tmp/bbb-ramdisk-$ID"
	mkdir $OUTPUT
	sudo touch $OUTPUT/console.log
	sudo chmod 666 $OUTPUT/console.log
	sudo cp ./bbb-01.conf /usr/lib/python2.7/dist-packages/lava_dispatcher/pipeline/devices/
	sudo lava-dispatch --target bbb-01 ./local-uboot-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
	rsync -az $OUTPUT ..

	DATE=`date +%s`
	ID=`expr $DATE - $START`
	OUTPUT="/tmp/bbb-nfs-$ID"
	mkdir $OUTPUT
	sudo touch $OUTPUT/console.log
	sudo chmod 666 $OUTPUT/console.log
	sudo cp ./bbb-01.conf /usr/lib/python2.7/dist-packages/lava_dispatcher/pipeline/devices/
	sudo lava-dispatch --target bbb-01 ./bbb-uboot-nfs.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
	rsync -az $OUTPUT ..
fi
