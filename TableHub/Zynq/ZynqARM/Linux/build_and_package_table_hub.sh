#!/bin/sh

set -x
set -e

#cp /home/bdsound/Project/zynq_array/Workspace/Vivado/table_hub/table_hub.sdk/fsbl/Debug/fsbl.elf ./fsbl_table_hub.elf
#cp /home/bdsound/Project/zynq_array/Workspace/Vivado/table_hub/table_hub.sdk/table_hub_design_wrapper_hw_platform_0/table_hub_design_wrapper.bit ./
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/audio_from_ps_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/audio_from_ps_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/audio_router/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/audio_router/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/audio_to_ps_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/audio_to_ps_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/bus_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/bus_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/gain_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/gain_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters.h ./components/modules/version_module/
cp ../../Build/fsbl_work/fsbl_bsp/ps7_cortexa9_0/include/xparameters_ps.h ./components/modules/version_module/

petalinux-build
petalinux-package --boot --force --fsbl ../../Build/fsbl_work/fsbl/Debug/fsbl.elf --fpga ../../Build/fsbl_work/table_hub_hw/table_hub_design_wrapper.bit --u-boot 
