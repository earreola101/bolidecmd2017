
# ####################################################################################################################
#!/usr/bin/tclsh
# #################################################################################################################### 
# Create and build xsdk project (fsbl and bare metal application)
# Open vivado
# In the TCL console:
#	cd to current directory 
#		e.g.
#		cd ~/repo/bdSound_Bolide/MicPod/Zynq/ZynqPL
#
# 	 xsdk -batch -source 00_fsbl_app_mic_pod.tcl 
# #################################################################################################################### 
# #################################################################################################################### 

# ################################################
# OPTIONS
# ################################################

set beginTime [clock seconds]

# First time export to sdk
file delete -force ../Build/sdk_work
file mkdir ../Build/sdk_work
file copy -force ../Build/mic_pod/mic_pod.runs/impl_1/mic_pod_design_wrapper.sysdef ../Build/sdk_work/mic_pod.hdf
setws ../Build/sdk_work


sdk createhw -name mic_pod_hw -hwspec ../Build/sdk_work/mic_pod.hdf
sdk createapp -name fsbl -hwproject mic_pod_hw -proc ps7_cortexa9_0 -os standalone -lang C -app {Zynq FSBL}
sdk createbsp -name bsp -hwproject mic_pod_hw -proc ps7_cortexa9_0 -os standalone
sdk importprojects ../ZynqARM/Project/

clean -type all
build -type all

set endTime [clock seconds]
set elapsed [expr {$endTime - $beginTime}]
puts "Time to elaborate: [clock format $elapsed -gmt true -format %H:%M:%S]"


