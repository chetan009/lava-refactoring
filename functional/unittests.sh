#!/bin/sh

./ci-run $@ 2>&1 | tee ci.log
RET=`echo $?`
if [ "$RET" != "0" ]; then
	lava-test-case logfile --result fail
	lava-test-case-attach logfile ci.log text/plain
fi
results=`grep -E "Ran [0-9]{3} tests in " ci.log | sed -E 's/^Ran ([0-9]{3}) tests in ([0-9\.]+)s$/\1 \2/'`
count=`echo $results|cut -d' ' -f 1`
time=`echo $results|cut -d' ' -f 2`
for line in `grep '\.\.\. ' ci.log |grep test | grep ok | awk '{print $1"_"$2":"$4}'`; do
	NAME=`echo $line|cut -d: -f1| tr -d '()' `
	lava-test-case "${NAME}" --result pass
done
for line in `grep '\.\.\. ' ci.log | grep ERROR | awk '{print $1"_"$2":"$4}'`; do
	NAME=`echo $line|cut -d: -f1| tr -d '()' `
	lava-test-case "${NAME}" --result fail
done
for line in `grep 'FAIL: test' ci.log|cut -d' ' -f2-`; do
	lava-test-case ${line} --result fail
done
if [ $count > 0 ]; then
	lava-test-case total-count --result pass --measurement ${count} --units tests
else
	lava-test-case total-count --result fail
fi
if [ $time > 0 ]; then
	lava-test-case overall-speed --result pass --measurement ${time} --units seconds
else
	lava-test-case overall-speed --result fail
fi
lava-test-case logfile --result pass
lava-test-case-attach logfile ci.log text/plain
