#!/bin/sh

set -x
set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   echo "sudo ./deploy_table_hub.sh <USER>"
   exit 1
fi

if [ "$1" != "" ]; then
    echo "Running script for user $1"
else
    echo "Wrong usage:"
    echo "sudo ./deploy_table_hub.sh <USER>"
fi

cp ZynqARM/Linux/images/linux/BOOT.BIN /media/$1/BOOT/
cp ZynqARM/Linux/images/linux/image.ub /media/$1/BOOT/
cp ZynqARM/Linux/additional-files/BOOT/interfaces /media/$1/BOOT/


cp ZynqARM/Linux/images/linux/rootfs.cpio /media/$1/rootfs/
cp ZynqARM/Linux/additional-files/rootfs/bd_startup /media/$1/rootfs/
cp ZynqARM/Linux/additional-files/rootfs/stm32flash.elf /media/$1/rootfs/
cp ZynqARM/Linux/additional-files/rootfs/tv_app_update.sh /media/$1/rootfs/
cp Build/app/tv_hub_app /media/$1/rootfs/
chmod +x /media/$1/rootfs/bd_startup
chmod +x /media/$1/rootfs/stm32flash.elf 
chmod +x /media/$1/rootfs/tv_app_update.sh
chmod +x /media/$1/rootfs/tv_hub_app 
sync