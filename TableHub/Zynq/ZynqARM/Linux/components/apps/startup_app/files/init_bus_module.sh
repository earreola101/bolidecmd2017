#!/bin/sh
set -x

killall tcf-agent
/usr/sbin/tcf-agent -d -L- -l0

rmmod bus_module.ko
rm /dev/bus0
rm /dev/bus1
rm /dev/bus2

insmod /lib/modules/3.17.0-xilinx/extra/bus_module.ko
mknod /dev/bus0 c 245 0
mknod /dev/bus1 c 245 1
mknod /dev/bus2 c 245 2

