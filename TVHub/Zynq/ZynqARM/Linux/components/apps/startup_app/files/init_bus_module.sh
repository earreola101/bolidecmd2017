#!/bin/sh
set -x

killall tcf-agent
/usr/sbin/tcf-agent -d -L- -l0

rmmod bus_module.ko
rm /dev/bus0

insmod /lib/modules/3.17.0-xilinx/extra/bus_module.ko
mknod /dev/bus0 c 245 0


