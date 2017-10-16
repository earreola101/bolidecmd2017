
create_bd_pin -dir I $hier_name/wclk


create_bd_pin -dir I $hier_name/clk_100M
create_bd_pin -dir I $hier_name/clk_100M_rst_n

create_bd_pin -dir I $hier_name/clk_16_384M
create_bd_pin -dir I $hier_name/clk_16_384M_rst_n
create_bd_pin -dir O $hier_name/audio_to_ps_intr
create_bd_pin -dir O $hier_name/audio_from_ps_intr
create_bd_pin -dir I $hier_name/i2s_lrclk
create_bd_pin -dir I $hier_name/i2s_bclk
create_bd_pin -dir O $hier_name/i2s_dout
create_bd_pin -dir O $hier_name/aes_dout
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_0
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_1
create_bd_pin -dir O -from 23 -to 0 $hier_name/mic_to_usb




create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_0
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_1
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_2
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_3
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_4
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_5
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_6
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_7
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_8
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_9
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_10
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_11
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_12
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_13
create_bd_intf_pin -mode Slave -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/audio_from_bus_14

create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_REG_TO_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_REG_FROM_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_BRAM_TO_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_BRAM_FROM_PS
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_GAIN_SPK

create_bd_cell -type ip -vlnv bdsound.com:user:audio_from_ps:1.0 $hier_name/audio_from_ps
set_property -dict [list CONFIG.CH_NUM {4}] [get_bd_cells $hier_name/audio_from_ps]
create_bd_cell -type ip -vlnv bdsound.com:user:audio_to_ps:1.0 $hier_name/audio_to_ps
set_property -dict [list CONFIG.CH_NUM {16}] [get_bd_cells $hier_name/audio_to_ps]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/bram_ctrl_to_ps
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/bram_ctrl_to_ps]
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/bram_to_ps

create_bd_cell -type ip -vlnv bdsound.com:user:gain_block:1.0 $hier_name/gain_block
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

create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_transmitter:1.0 $hier_name/i2s_spk
create_bd_cell -type ip -vlnv bdsound.com:user:bdAES3tx_simple:1.0 $hier_name/aes_spk
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 $hier_name/reset_not
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells $hier_name/reset_not]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/aes_freq_const
set_property -dict [list CONFIG.CONST_WIDTH {2} CONFIG.CONST_VAL {2}] [get_bd_cells $hier_name/aes_freq_const]



connect_bd_net 	[get_bd_pins $hier_name/clk_100M] \
				[get_bd_pins $hier_name/audio_from_ps/clk] \
				[get_bd_pins $hier_name/audio_to_ps/clk] \
				[get_bd_pins $hier_name/bram_ctrl_from_ps/s_axi_aclk] \
				[get_bd_pins $hier_name/bram_ctrl_to_ps/s_axi_aclk] \
				[get_bd_pins $hier_name/i2s_spk/clk] \
				[get_bd_pins $hier_name/gain_block/clk]
				
connect_bd_net 	[get_bd_pins $hier_name/clk_100M_rst_n] \
				[get_bd_pins $hier_name/bram_ctrl_to_ps/s_axi_aresetn] \
				[get_bd_pins $hier_name/audio_to_ps/rst_n] \
				[get_bd_pins $hier_name/bram_ctrl_from_ps/s_axi_aresetn] \
				[get_bd_pins $hier_name/audio_from_ps/rst_n] \
				[get_bd_pins $hier_name/i2s_spk/rst_n] \
				[get_bd_pins $hier_name/gain_block/rst_n]

connect_bd_net 	[get_bd_pins $hier_name/wclk] \
				[get_bd_pins $hier_name/audio_to_ps/lrclk] \
				[get_bd_pins $hier_name/audio_from_ps/lrclk] \
				[get_bd_pins $hier_name/gain_block/lrclk]


#Axi and brams
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_BRAM_FROM_PS] [get_bd_intf_pins $hier_name/bram_ctrl_from_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_BRAM_TO_PS] [get_bd_intf_pins $hier_name/bram_ctrl_to_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_REG_FROM_PS] [get_bd_intf_pins $hier_name/audio_from_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_REG_TO_PS] [get_bd_intf_pins $hier_name/audio_to_ps/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bram_ctrl_from_ps/BRAM_PORTA] [get_bd_intf_pins $hier_name/bram_from_ps/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bram_ctrl_to_ps/BRAM_PORTA] [get_bd_intf_pins $hier_name/bram_to_ps/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bram_to_ps/BRAM_PORTA] [get_bd_intf_pins $hier_name/audio_to_ps/bram]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_ps/bram] [get_bd_intf_pins $hier_name/bram_from_ps/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_GAIN_SPK] [get_bd_intf_pins $hier_name/gain_block/S_AXI]


connect_bd_net [get_bd_pins $hier_name/audio_from_ps_intr] [get_bd_pins $hier_name/audio_from_ps/intr]
connect_bd_net [get_bd_pins $hier_name/audio_to_ps_intr] [get_bd_pins $hier_name/audio_to_ps/intr]

connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_0]  [get_bd_intf_pins $hier_name/audio_to_ps/in0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_1]  [get_bd_intf_pins $hier_name/audio_to_ps/in1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_2]  [get_bd_intf_pins $hier_name/audio_to_ps/in2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_3]  [get_bd_intf_pins $hier_name/audio_to_ps/in3]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_4]  [get_bd_intf_pins $hier_name/audio_to_ps/in4]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_5]  [get_bd_intf_pins $hier_name/audio_to_ps/in5]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_6]  [get_bd_intf_pins $hier_name/audio_to_ps/in6]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_7]  [get_bd_intf_pins $hier_name/audio_to_ps/in7]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_8]  [get_bd_intf_pins $hier_name/audio_to_ps/in8]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_9]  [get_bd_intf_pins $hier_name/audio_to_ps/in9]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_10] [get_bd_intf_pins $hier_name/audio_to_ps/in10]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_11] [get_bd_intf_pins $hier_name/audio_to_ps/in11]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_12] [get_bd_intf_pins $hier_name/audio_to_ps/in12]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_13] [get_bd_intf_pins $hier_name/audio_to_ps/in13]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_from_bus_14] [get_bd_intf_pins $hier_name/audio_to_ps/in14]

connect_bd_net 	[get_bd_pins $hier_name/audio_from_ps/out0] \
				[get_bd_pins $hier_name/spk_0]
				
connect_bd_net 	[get_bd_pins $hier_name/audio_from_ps/out1] \
				[get_bd_pins $hier_name/spk_1]
				



connect_bd_net [get_bd_pins $hier_name/aes_freq_const/dout] [get_bd_pins $hier_name/aes_spk/out_freq]				


connect_bd_net [get_bd_pins $hier_name/audio_from_ps/enable] [get_bd_pins $hier_name/i2s_spk/enable]

connect_bd_net [get_bd_pins $hier_name/i2s_bclk] [get_bd_pins $hier_name/i2s_spk/i2s_bclk]
connect_bd_net [get_bd_pins $hier_name/i2s_lrclk] [get_bd_pins $hier_name/i2s_spk/i2s_lrclk]

connect_bd_net [get_bd_pins $hier_name/clk_16_384M_rst_n] [get_bd_pins $hier_name/reset_not/Op1]
connect_bd_net [get_bd_pins $hier_name/reset_not/Res] [get_bd_pins $hier_name/aes_spk/rst]

# connect_bd_net [get_bd_pins $hier_name/clk_16_384M_rst_n] [get_bd_pins $hier_name/aes_spk/rst]
connect_bd_net [get_bd_pins $hier_name/clk_16_384M] [get_bd_pins $hier_name/aes_spk/audio_clk]

connect_bd_net [get_bd_pins $hier_name/aes_dout] [get_bd_pins $hier_name/aes_spk/dout]
connect_bd_net [get_bd_pins $hier_name/i2s_dout] [get_bd_pins $hier_name/i2s_spk/i2s_data_out]
connect_bd_net [get_bd_pins $hier_name/mic_to_usb] [get_bd_pins $hier_name/audio_from_ps/out2]

connect_bd_net [get_bd_pins $hier_name/audio_from_ps/out0] [get_bd_pins $hier_name/gain_block/in0]
connect_bd_net [get_bd_pins $hier_name/audio_from_ps/out1] [get_bd_pins $hier_name/gain_block/in1]

connect_bd_net 	[get_bd_pins $hier_name/gain_block/out0] \
				[get_bd_pins $hier_name/i2s_spk/ch0] \
				[get_bd_pins $hier_name/aes_spk/ch0_in]
				
connect_bd_net 	[get_bd_pins $hier_name/gain_block/out1] \
				[get_bd_pins $hier_name/i2s_spk/ch1] \
				[get_bd_pins $hier_name/aes_spk/ch1_in]