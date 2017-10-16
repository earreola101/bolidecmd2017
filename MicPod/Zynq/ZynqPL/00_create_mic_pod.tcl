# ####################################################################################################################
# #################################################################################################################### 
# Create vivado project
# Open vivado
# In the TCL console:
#	cd to current directory 
#		e.g.
#		cd ~/repo/bdSound_Bolide/MicPod/Zynq/ZynqPL
#
# 	vivado -mode batch -source ./00_create_mic_pod.tcl
# #################################################################################################################### 
# #################################################################################################################### 

# ################################################
# OPTIONS
# ################################################

source ./version.tcl

set bus_ch_num	15
set beginTime [clock seconds]


file delete -force ../Build/mic_pod

create_project mic_pod ../Build/mic_pod -part xc7z007sclg225-2
set_property target_language VHDL [current_project]

set_property  ip_repo_paths  ./ips [current_project]
update_ip_catalog


source ./01_top.tcl

assign_bd_address
set_property range 32K [get_bd_addr_segs {processing_system7_0/Data/SEG_bram_ctrl_from_ps_Mem0}]
set_property range 32K [get_bd_addr_segs {processing_system7_0/Data/SEG_bram_ctrl_to_ps_Mem0}]

add_files -norecurse ./mic_pod.vhd
add_files -fileset constrs_1 -norecurse ./mic_pod.xdc
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

validate_bd_design
regenerate_bd_layout
save_bd_design


set endTime [clock seconds]
set elapsed [expr {$endTime - $beginTime}]
puts "Time to elaborate: [clock format $elapsed -gmt true -format %H:%M:%S]"
























