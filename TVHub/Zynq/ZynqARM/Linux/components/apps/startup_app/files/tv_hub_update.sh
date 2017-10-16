#!/bin/sh
set -x
set -e

killall tv_hub_app
mv /media/rootfs/tv_hub_app_upd /media/rootfs/tv_hub_app
sync
chmod +x /media/rootfs/tv_hub_app
reboot
