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

DATE=`date +"%Y.%m.%d.%H.%M"`

#panda

cd /home/neil/code/lava/pipeline/git/scripts/
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
OUTPUT="./cron/yogi/panda-ramdisk-$DATE"
mkdir -p $OUTPUT
/usr/sbin/lava-dispatch --target yogi ../panda-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log

DATE=`date +"%Y.%m.%d.%H.%M"`
OUTPUT="./cron/paddington/panda-ramdisk-$DATE"
mkdir -p $OUTPUT
/usr/sbin/lava-dispatch --target paddington ../panda-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log

chown -R neil:neil ./cron/
