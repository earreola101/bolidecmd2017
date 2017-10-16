
# ####################################################################################################################
# #################################################################################################################### 
# Build vivado project
# Open vivado
# In the TCL console:
#	cd to current directory 
#		e.g.
#		cd ~/repo/bdSound_Bolide/TableHub/Zynq/ZynqPL
#
# 	vivado -mode batch -source ./00_build_table_hub.tcl 
# #################################################################################################################### 
# #################################################################################################################### 

# ################################################
# OPTIONS
# ################################################

set beginTime [clock seconds]


open_project ../Build/table_hub/table_hub.xpr

#comment to avoid project build
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

set endTime [clock seconds]
set elapsed [expr {$endTime - $beginTime}]
puts "Time to elaborate: [clock format $elapsed -gmt true -format %H:%M:%S]"


