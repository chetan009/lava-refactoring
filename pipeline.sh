#!/bin/sh

# set -e

START=1416310894

DATE=`date +%s`

ID=`expr $DATE - $START`
OUTPUT="/tmp/kvm-$ID"
mkdir $OUTPUT
sudo touch $OUTPUT/console.log
sudo chmod 666 $OUTPUT/console.log
sudo lava-dispatch --target kvm01 ./local-kvm.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
rsync -az $OUTPUT .

DATE=`date +%s`
ID=`expr $DATE - $START`
OUTPUT="/tmp/bbb-ramdisk-$ID"
mkdir $OUTPUT
sudo touch $OUTPUT/console.log
sudo chmod 666 $OUTPUT/console.log
sudo lava-dispatch --target bbb-01 ./local-uboot-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
rsync -az $OUTPUT .

DATE=`date +%s`
ID=`expr $DATE - $START`
OUTPUT="/tmp/bbb-nfs-$ID"
mkdir $OUTPUT
sudo touch $OUTPUT/console.log
sudo chmod 666 $OUTPUT/console.log
sudo lava-dispatch --target bbb-01 ./local-uboot-pipeline.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
rsync -az $OUTPUT .

exit 0

DATE=`date +%s`
ID=`expr $DATE - $START`
OUTPUT="/tmp/panda-ramdisk-$ID"
mkdir $OUTPUT
sudo touch $OUTPUT/console.log
sudo lava-dispatch --target panda-es-01 ./panda-ramdisk.yaml --output-dir=$OUTPUT | tee $OUTPUT/console.log
rsync -az $OUTPUT .

