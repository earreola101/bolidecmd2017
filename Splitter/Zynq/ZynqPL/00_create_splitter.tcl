# ####################################################################################################################
# #################################################################################################################### 
# Create vivado project
# Open vivado
# In the TCL console:
#	cd to current directory 
#		e.g.
#		cd ~/repo/bdSound_Bolide/Splitter/Zynq/ZynqPL
#
# 	vivado -mode batch -source ./00_create_splitter.tcl
# #################################################################################################################### 
# #################################################################################################################### 

# ################################################
# OPTIONS
# ################################################

source ./version.tcl

set bus_ch_num	15
set beginTime [clock seconds]


file delete -force ../Build/splitter

create_project splitter ../Build/splitter -part xc7z007sclg225-2
set_property target_language VHDL [current_project]

set_property  ip_repo_paths  ./ips [current_project]
update_ip_catalog


source ./01_top.tcl

assign_bd_address

add_files -norecurse ./splitter.vhd
add_files -fileset constrs_1 -norecurse ./splitter.xdc
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

validate_bd_design
regenerate_bd_layout
save_bd_design


set endTime [clock seconds]
set elapsed [expr {$endTime - $beginTime}]
puts "Time to elaborate: [clock format $elapsed -gmt true -format %H:%M:%S]"
























