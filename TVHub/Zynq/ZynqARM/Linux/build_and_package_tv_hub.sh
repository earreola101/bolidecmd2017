#!/bin/sh

set -x
set -e

cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/bus_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/bus_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/gain_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/gain_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/version_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/version_module/

petalinux-build
petalinux-package --boot --force --fsbl ../../Build/fsbl_work/fsbl/Debug/fsbl.elf --fpga ../../Build/fsbl_work/tv_hub_hw/tv_hub_design_wrapper.bit --u-boot 
