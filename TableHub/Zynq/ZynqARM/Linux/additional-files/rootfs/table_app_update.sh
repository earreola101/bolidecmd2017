#!/bin/sh
set -x
set -e

killall table_hub_app
mv /media/rootfs/table_hub_app_ /media/rootfs/table_hub_app
cp /media/rootfs/table_hub_app /media/rootfs/table_hub_app_
chmod +x /media/rootfs/table_hub_app
sync
reboot
