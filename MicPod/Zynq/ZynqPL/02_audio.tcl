
create_bd_pin -dir I $hier_name/i2s_wclk
create_bd_pin -dir I $hier_name/i2s_bclk
create_bd_pin -dir I $hier_name/i2s_din0
create_bd_pin -dir I $hier_name/i2s_din1

create_bd_pin -dir I $hier_name/clk_100M
create_bd_pin -dir I $hier_name/clk_100M_rst_n

create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_0
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_1

create_bd_pin -dir O $hier_name/audio_to_ps_intr
create_bd_pin -dir O $hier_name/audio_from_ps_intr

create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_0
create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_1
create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_2
create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_3
create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_4
create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_5
create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_6

create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_REG_TO_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_REG_FROM_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_BRAM_TO_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_BRAM_FROM_PS

create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_receiver:1.0 $hier_name/i2s_receiver_0
create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_receiver:1.0 $hier_name/i2s_receiver_1
create_bd_cell -type ip -vlnv bdsound.com:user:audio_from_ps:1.0 $hier_name/audio_from_ps
create_bd_cell -type ip -vlnv bdsound.com:user:audio_to_ps:1.0 $hier_name/audio_to_ps
set_property -dict [list CONFIG.CH_NUM {6}] [get_bd_cells $hier_name/audio_to_ps]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/bram_ctrl_to_ps
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/bram_ctrl_to_ps]
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/bram_to_ps
#Write_Depth_A
#0.010ms*32000Hz*6ch*2buffer=3840->4096
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
					] [get_bd_cells $hier_name/bram_to_ps]
					
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/bram_ctrl_from_ps	
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/bram_ctrl_from_ps]
		
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/bram_from_ps
#Write_Depth_A
#0.010ms*32000Hz*8ch*2buffer=5120->8192
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
					] [get_bd_cells $hier_name/bram_from_ps]




connect_bd_net 	[get_bd_pins $hier_name/clk_100M] \
				[get_bd_pins $hier_name/i2s_receiver_0/mclk] \
				[get_bd_pins $hier_name/i2s_receiver_1/mclk] \
				[get_bd_pins $hier_name/audio_from_ps/clk] \
				[get_bd_pins $hier_name/audio_to_ps/clk] \
				[get_bd_pins $hier_name/bram_ctrl_from_ps/s_axi_aclk] \
				[get_bd_pins $hier_name/bram_ctrl_to_ps/s_axi_aclk]
				

connect_bd_net 	[get_bd_pins $hier_name/clk_100M_rst_n] \
				[get_bd_pins $hier_name/i2s_receiver_0/rst_n] \
				[get_bd_pins $hier_name/i2s_receiver_1/rst_n] \
				[get_bd_pins $hier_name/bram_ctrl_to_ps/s_axi_aresetn] \
				[get_bd_pins $hier_name/audio_to_ps/rst_n] \
				[get_bd_pins $hier_name/bram_ctrl_from_ps/s_axi_aresetn] \
				[get_bd_pins $hier_name/audio_from_ps/rst_n]

connect_bd_net 	[get_bd_pins $hier_name/audio_to_ps/enable] \
				[get_bd_pins $hier_name/i2s_receiver_0/enable] \
				[get_bd_pins $hier_name/i2s_receiver_1/enable]


connect_bd_net 	[get_bd_pins $hier_name/i2s_bclk] \
				[get_bd_pins $hier_name/i2s_receiver_0/i2s_bclk] \
				[get_bd_pins $hier_name/i2s_receiver_1/i2s_bclk]

connect_bd_net 	[get_bd_pins $hier_name/i2s_wclk] \
				[get_bd_pins $hier_name/i2s_receiver_0/i2s_lrclk] \
				[get_bd_pins $hier_name/i2s_receiver_1/i2s_lrclk] \
				[get_bd_pins $hier_name/audio_to_ps/lrclk] \
				[get_bd_pins $hier_name/audio_from_ps/lrclk]
				
# connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_0] [get_bd_intf_pins $hier_name/i2s_receiver_0/audio_0]
# connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_1] [get_bd_intf_pins $hier_name/i2s_receiver_0/audio_1]
# connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_2] [get_bd_intf_pins $hier_name/i2s_receiver_1/audio_0]
# connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_3] [get_bd_intf_pins $hier_name/i2s_receiver_1/audio_1]

connect_bd_net [get_bd_pins $hier_name/i2s_din0] [get_bd_pins $hier_name/i2s_receiver_0/i2s_data_in]
connect_bd_net [get_bd_pins $hier_name/i2s_din1] [get_bd_pins $hier_name/i2s_receiver_1/i2s_data_in]

#Axi and brams
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_BRAM_FROM_PS] [get_bd_intf_pins $hier_name/bram_ctrl_from_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_BRAM_TO_PS] [get_bd_intf_pins $hier_name/bram_ctrl_to_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_REG_FROM_PS] [get_bd_intf_pins $hier_name/audio_from_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_REG_TO_PS] [get_bd_intf_pins $hier_name/audio_to_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bram_ctrl_from_ps/BRAM_PORTA] [get_bd_intf_pins $hier_name/bram_from_ps/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bram_ctrl_to_ps/BRAM_PORTA] [get_bd_intf_pins $hier_name/bram_to_ps/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bram_to_ps/BRAM_PORTA] [get_bd_intf_pins $hier_name/audio_to_ps/bram]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_ps/bram] [get_bd_intf_pins $hier_name/bram_from_ps/BRAM_PORTA]

connect_bd_net [get_bd_pins $hier_name/i2s_receiver_0/ch0] [get_bd_pins $hier_name/audio_to_ps/in0]
connect_bd_net [get_bd_pins $hier_name/i2s_receiver_0/ch1] [get_bd_pins $hier_name/audio_to_ps/in1]
connect_bd_net [get_bd_pins $hier_name/i2s_receiver_1/ch0] [get_bd_pins $hier_name/audio_to_ps/in2]
connect_bd_net [get_bd_pins $hier_name/i2s_receiver_1/ch1] [get_bd_pins $hier_name/audio_to_ps/in3]
connect_bd_net [get_bd_pins $hier_name/spk_0] [get_bd_pins $hier_name/audio_to_ps/in4]
connect_bd_net [get_bd_pins $hier_name/spk_1] [get_bd_pins $hier_name/audio_to_ps/in5]

connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_0] [get_bd_intf_pins $hier_name/audio_from_ps/audio_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_1] [get_bd_intf_pins $hier_name/audio_from_ps/audio_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_2] [get_bd_intf_pins $hier_name/audio_from_ps/audio_2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_3] [get_bd_intf_pins $hier_name/audio_from_ps/audio_3]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_4] [get_bd_intf_pins $hier_name/audio_from_ps/audio_4]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_5] [get_bd_intf_pins $hier_name/audio_from_ps/audio_5]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_6] [get_bd_intf_pins $hier_name/audio_from_ps/audio_6]

connect_bd_net [get_bd_pins $hier_name/audio_from_ps_intr] [get_bd_pins $hier_name/audio_from_ps/intr]
connect_bd_net [get_bd_pins $hier_name/audio_to_ps_intr] [get_bd_pins $hier_name/audio_to_ps/intr]
