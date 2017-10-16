#general ports
create_bd_pin -dir I $hier_name/clk_20_48M_int_0
create_bd_pin -dir I $hier_name/clk_20_48M_int_90
create_bd_pin -dir I $hier_name/clk_20_48M_int_180
create_bd_pin -dir I $hier_name/clk_20_48M_int_270
create_bd_pin -dir I $hier_name/clk_20_48M_int_rst_n
create_bd_pin -dir I $hier_name/clk_20_48M_ext
create_bd_pin -dir I $hier_name/clk_20_48M_ext_rst_n

create_bd_pin -dir I $hier_name/clk_100M
create_bd_pin -dir I $hier_name/clk_100M_rst_n
create_bd_pin -dir I $hier_name/wclk_ext

create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/COMM_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/RX_BRAM_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/TX_BRAM_AXI

create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_0_to_spk
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_1_to_spk
create_bd_pin -dir O $hier_name/bus_locked

create_bd_pin -dir O -from 23 -to 0 $hier_name/mic_to_usb
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_0_from_usb
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_1_from_usb


create_bd_pin -dir I $hier_name/RX
create_bd_pin -dir O $hier_name/TX
create_bd_pin -dir O $hier_name/DIR

create_bd_pin -dir O -from 1 -to 0 $hier_name/INTR

create_bd_pin -dir O $hier_name/PLL_WCLK
				
#############################################
# receiver 0
#############################################

create_bd_cell -type ip -vlnv bdsound.com:user:bus_receiver:1.0 $hier_name/bus_receiver
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_receiver]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_recover:1.0 $hier_name/packet_recover
set_property -dict [list CONFIG.TRUE_BRAM {true}] [get_bd_cells $hier_name/packet_recover]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/packet_recover_int_mem
set_property -dict [list \
						CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
						CONFIG.Write_Width_A {8} \
						CONFIG.Write_Depth_A {4096} \
						CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
						CONFIG.use_bram_block {Stand_Alone} \
						CONFIG.Enable_32bit_Address {false} \
						CONFIG.Use_Byte_Write_Enable {false} \
						CONFIG.Byte_Size {9} \
						CONFIG.Read_Width_A {8} \
						CONFIG.Operating_Mode_A {NO_CHANGE} \
						CONFIG.Write_Width_B {8} \
						CONFIG.Read_Width_B {8} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
						CONFIG.Use_RSTA_Pin {false} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Enable_Rate {100} \
					] [get_bd_cells $hier_name/packet_recover_int_mem]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/rx_data_bram
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Write_Depth_A {256} \
					] [get_bd_cells $hier_name/rx_data_bram]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/rx_data_bram_ctrl
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/rx_data_bram_ctrl]

		
#connections
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem/BRAM_PORTA] [get_bd_intf_pins $hier_name/packet_recover/circular_bram_w]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem/BRAM_PORTB] [get_bd_intf_pins $hier_name/packet_recover/circular_bram_r]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver/data_0] [get_bd_intf_pins $hier_name/packet_recover/data_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver/data_1] [get_bd_intf_pins $hier_name/packet_recover/data_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver/data_2] [get_bd_intf_pins $hier_name/packet_recover/data_2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover/packet_bram_f] [get_bd_intf_pins $hier_name/rx_data_bram/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/rx_data_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins $hier_name/rx_data_bram/BRAM_PORTB]
connect_bd_net 	[get_bd_pins $hier_name/bus_receiver/wclk] [get_bd_pins $hier_name/packet_recover/wclk]
				
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_BRAM_AXI] [get_bd_intf_pins $hier_name/rx_data_bram_ctrl/S_AXI]


connect_bd_net [get_bd_pins $hier_name/RX] [get_bd_pins $hier_name/bus_receiver/din]

#############################################
# transmitter
#############################################

#create and configure  ips
create_bd_cell -type ip -vlnv bdsound.com:user:bus_transmitter:1.0 $hier_name/bus_transmitter
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_transmitter]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_sender:1.0 $hier_name/packet_sender
set_property -dict [list CONFIG.PORT_1_TRUE_BRAM {true}] [get_bd_cells $hier_name/packet_sender]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/valid
set_property -dict [list CONFIG.CONST_VAL {1}] [get_bd_cells $hier_name/valid]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/mute
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells $hier_name/mute]

#external bram to the processor
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/tx_data_bram
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Write_Depth_A {256} \
					] [get_bd_cells $hier_name/tx_data_bram]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/tx_data_bram_ctrl
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/tx_data_bram_ctrl]


#connections
connect_bd_net 	[get_bd_pins $hier_name/wclk_ext] \
				[get_bd_pins $hier_name/packet_sender/wclk] \
				[get_bd_pins $hier_name/bus_transmitter/wclk] \
				[get_bd_pins $hier_name/audio_router/wclk]

connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_sender/data_0] [get_bd_intf_pins $hier_name/bus_transmitter/data_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_sender/data_1] [get_bd_intf_pins $hier_name/bus_transmitter/data_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_sender/data_2] [get_bd_intf_pins $hier_name/bus_transmitter/data_2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_sender/packet1_bram_f] [get_bd_intf_pins $hier_name/tx_data_bram/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/tx_data_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins $hier_name/tx_data_bram/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins $hier_name/TX_BRAM_AXI] [get_bd_intf_pins $hier_name/tx_data_bram_ctrl/S_AXI]


connect_bd_net 	[get_bd_pins $hier_name/bus_transmitter/dout] [get_bd_pins $hier_name/TX]
				

#############################################
# command manager
#############################################

#create and configure  ips
create_bd_cell -type ip -vlnv bdsound.com:user:comm_manager:1.0 $hier_name/comm_manager

#connections
connect_bd_intf_net [get_bd_intf_pins $hier_name/comm_manager/TX] [get_bd_intf_pins $hier_name/packet_sender/packet1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/comm_manager/RX] [get_bd_intf_pins $hier_name/packet_recover/packet]

connect_bd_net 	[get_bd_pins $hier_name/bus_receiver/locked] \
				[get_bd_pins $hier_name/comm_manager/HUB_LOCKED] \
				[get_bd_pins $hier_name/bus_locked]
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/COMM_AXI] [get_bd_intf_pins $hier_name/comm_manager/S_AXI]

connect_bd_net [get_bd_pins $hier_name/INTR] [get_bd_pins $hier_name/comm_manager/INTR]

#############################################
# clock and rst
#############################################


#clock
connect_bd_net 	[get_bd_pins $hier_name/clk_100M] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl/s_axi_aclk] \
				[get_bd_pins $hier_name/comm_manager/S_AXI_ACLK] \
				[get_bd_pins $hier_name/tx_data_bram_ctrl/s_axi_aclk]

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_0] \
				[get_bd_pins $hier_name/bus_receiver/clk_0] \
				[get_bd_pins $hier_name/packet_recover/clk] \
				[get_bd_pins $hier_name/comm_manager/clk_rx]
				
connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_ext] \
				[get_bd_pins $hier_name/bus_transmitter/clk] \
				[get_bd_pins $hier_name/packet_sender/clk] \
				[get_bd_pins $hier_name/comm_manager/clk_tx]
				
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_90] [get_bd_pins $hier_name/bus_receiver/clk_90]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_180] [get_bd_pins $hier_name/bus_receiver/clk_180]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_270] [get_bd_pins $hier_name/bus_receiver/clk_270]

#reset
connect_bd_net 	[get_bd_pins $hier_name/clk_100M_rst_n] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl/s_axi_aresetn] \
				[get_bd_pins $hier_name/comm_manager/S_AXI_ARESETN] \
				[get_bd_pins $hier_name/tx_data_bram_ctrl/s_axi_aresetn]

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_rst_n] \
				[get_bd_pins $hier_name/bus_receiver/rst_n] \
				[get_bd_pins $hier_name/packet_recover/rst_n]

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_ext_rst_n] \
				[get_bd_pins $hier_name/bus_transmitter/rst_n] \
				[get_bd_pins $hier_name/packet_sender/rst_n]
				
#enable
connect_bd_net 	[get_bd_pins $hier_name/comm_manager/ENABLE_RX] \
				[get_bd_pins $hier_name/packet_recover/enable] \
				[get_bd_pins $hier_name/bus_receiver/enable]
				

connect_bd_net 	[get_bd_pins $hier_name/comm_manager/ENABLE_TX] \
				[get_bd_pins $hier_name/bus_transmitter/enable] \
				[get_bd_pins $hier_name/packet_sender/enable]
				
connect_bd_net 	[get_bd_pins $hier_name/comm_manager/DIR] [get_bd_pins $hier_name/DIR]


connect_bd_net [get_bd_pins $hier_name/spk_0_from_usb] [get_bd_pins $hier_name/bus_transmitter/audio_data_0]
connect_bd_net [get_bd_pins $hier_name/spk_1_from_usb] [get_bd_pins $hier_name/bus_transmitter/audio_data_1]

connect_bd_net 	[get_bd_pins $hier_name/mute/dout] \
				[get_bd_pins $hier_name/bus_transmitter/audio_mute_0] \
				[get_bd_pins $hier_name/bus_transmitter/audio_mute_1]
				
connect_bd_net 	[get_bd_pins $hier_name/valid/dout] \
				[get_bd_pins $hier_name/bus_transmitter/audio_valid_0] \
				[get_bd_pins $hier_name/bus_transmitter/audio_valid_1]
				
connect_bd_net [get_bd_pins $hier_name/spk_0_to_spk] [get_bd_pins $hier_name/bus_receiver/audio_data_0]
connect_bd_net [get_bd_pins $hier_name/spk_1_to_spk] [get_bd_pins $hier_name/bus_receiver/audio_data_1]
connect_bd_net [get_bd_pins $hier_name/mic_to_usb] [get_bd_pins $hier_name/bus_receiver/audio_data_2]

connect_bd_net [get_bd_pins $hier_name/PLL_WCLK] [get_bd_pins $hier_name/bus_receiver/wclk]
