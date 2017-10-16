
# ####################################################################################################################
#!/usr/bin/tclsh
# #################################################################################################################### 
# Create and build vivado project
# Open vivado
# In the TCL console:
#	cd to current directory 
#		e.g.
#		cd ~/repo/bdSound_Bolide/TableHub/Zynq/ZynqPL
#
# 	 xsdk -batch -source 00_fsbl_table_hub.tcl 
# #################################################################################################################### 
# #################################################################################################################### 

# ################################################
# OPTIONS
# ################################################

set beginTime [clock seconds]

# First time export to sdk
file delete -force ../Build/fsbl_work
file mkdir ../Build/fsbl_work
file copy -force ../Build/table_hub/table_hub.runs/impl_1/table_hub_design_wrapper.sysdef ../Build/fsbl_work/table_hub.hdf
setws ../Build/fsbl_work


sdk createhw -name table_hub_hw -hwspec ../Build/fsbl_work/table_hub.hdf
sdk createapp -name fsbl -hwproject table_hub_hw -proc ps7_cortexa9_0 -os standalone -lang C -app {Zynq FSBL}

hsi::open_sw_design ../Build/fsbl_work/fsbl_bsp/system.mss
hsi::set_property CONFIG.stdin ps7_uart_1 [hsi::get_os]
hsi::set_property CONFIG.stdout ps7_uart_1 [hsi::get_os]
hsi::generate_bsp -sw_mss ../Build/fsbl_work/fsbl_bsp/system.mss -dir [file dirname ../Build/fsbl_work/fsbl_bsp/system.mss]
hsi::close_sw_design [hsi::current_sw_design]

clean -type all
build -type all

set endTime [clock seconds]
set elapsed [expr {$endTime - $beginTime}]
puts "Time to elaborate: [clock format $elapsed -gmt true -format %H:%M:%S]"


