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

# This version *can* run in dummy-host - it is up to the user to handle
# the likely confusion in the mixed log files from old & new.

DATE=`date +"%Y.%m.%d.%H.%M"`

#panda

DATE=`date +"%Y.%m.%d.%H.%M"`
OUTPUT="../panda-ramdisk-$DATE"
mkdir $OUTPUT
touch $OUTPUT/console.log
chmod 666 $OUTPUT/console.log
lava-dispatch --target panda-es-01 ./yaml/panda-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log

# bbb

DATE=`date +"%Y.%m.%d.%H.%M"`
OUTPUT="../bbb-ramdisk-$DATE"
mkdir $OUTPUT
touch $OUTPUT/console.log
chmod 666 $OUTPUT/console.log
lava-dispatch --target bbb-01 ./yaml/local-uboot-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log

DATE=`date +"%Y.%m.%d.%H.%M"`
OUTPUT="../bbb-nfs-$DATE"
mkdir $OUTPUT
touch $OUTPUT/console.log
chmod 666 $OUTPUT/console.log
lava-dispatch --target bbb-01 ./yaml/bbb-nfs.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
