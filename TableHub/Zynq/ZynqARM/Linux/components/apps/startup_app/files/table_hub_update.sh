#!/bin/sh
set -x
set -e

killall table_hub_app
mv /media/rootfs/table_hub_app_upd /media/rootfs/table_hub_app
sync
chmod +x /media/rootfs/table_hub_app
reboot
