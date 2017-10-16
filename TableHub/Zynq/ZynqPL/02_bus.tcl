#general ports
create_bd_pin -dir I $hier_name/clk_20_48M_int_0
create_bd_pin -dir I $hier_name/clk_20_48M_int_90
create_bd_pin -dir I $hier_name/clk_20_48M_int_180
create_bd_pin -dir I $hier_name/clk_20_48M_int_270
create_bd_pin -dir I $hier_name/clk_20_48M_int_lock
create_bd_pin -dir I $hier_name/clk_20_48M_int_rst_n
create_bd_pin -dir I $hier_name/clk_20_48M_ext
create_bd_pin -dir I $hier_name/clk_20_48M_ext_lock
create_bd_pin -dir I $hier_name/clk_20_48M_ext_rst_n

create_bd_pin -dir I $hier_name/clk_100M
create_bd_pin -dir I $hier_name/clk_100M_rst_n
create_bd_pin -dir I $hier_name/wclk_ext
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AUDIO_ROUTER_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/COMM_0_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/COMM_1_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/COMM_2_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/RX_0_BRAM_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/RX_1_BRAM_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/RX_2_BRAM_AXI
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/TX_BRAM_AXI


for {set i 0} {$i < $bus_ch_num} {incr i} {
	create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/RX_AUDIO_$i
}

create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_0
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_1


create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_0_from_usb
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_1_from_usb
create_bd_pin -dir I -from 23 -to 0 $hier_name/mic_to_usb

create_bd_pin -dir I $hier_name/RX_0
create_bd_pin -dir I $hier_name/RX_1
create_bd_pin -dir I $hier_name/RX_2
create_bd_pin -dir O $hier_name/TX_0
create_bd_pin -dir O $hier_name/TX_1
create_bd_pin -dir O $hier_name/TX_2
create_bd_pin -dir O $hier_name/DIR_0
create_bd_pin -dir O $hier_name/DIR_1
create_bd_pin -dir O $hier_name/DIR_2
create_bd_pin -dir O -from 1 -to 0 $hier_name/INTR_0
create_bd_pin -dir O -from 1 -to 0 $hier_name/INTR_1
create_bd_pin -dir O -from 1 -to 0 $hier_name/INTR_2


create_bd_cell -type ip -vlnv bdsound.com:user:audio_router:1.0 $hier_name/audio_router
set_property -dict [list CONFIG.INTERFACE_NUMBER {3}] [get_bd_cells $hier_name/audio_router]
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3  $hier_name/audio_router_mem

set_property -dict [list \
						CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
						CONFIG.Write_Width_A {26} \
						CONFIG.Write_Depth_A {64} \
						CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
						CONFIG.use_bram_block {Stand_Alone} \
						CONFIG.Enable_32bit_Address {false} \
						CONFIG.Use_Byte_Write_Enable {false} \
						CONFIG.Byte_Size {9} \
						CONFIG.Read_Width_A {26} \
						CONFIG.Operating_Mode_A {NO_CHANGE} \
						CONFIG.Write_Width_B {26} \
						CONFIG.Read_Width_B {26} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
						CONFIG.Use_RSTA_Pin {false} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Enable_Rate {100} \
					] [get_bd_cells  $hier_name/audio_router_mem]
					
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_router_mem/BRAM_PORTA] [get_bd_intf_pins $hier_name/audio_router/int_bram_w]
connect_bd_intf_net [get_bd_intf_pins $hier_name/audio_router_mem/BRAM_PORTB] [get_bd_intf_pins $hier_name/audio_router/int_bram_r]	
				
#############################################
# receiver 0
#############################################

create_bd_cell -type ip -vlnv bdsound.com:user:bus_receiver:1.0 $hier_name/bus_receiver_0
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_receiver_0]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_recover:1.0 $hier_name/packet_recover_0
set_property -dict [list CONFIG.TRUE_BRAM {true}] [get_bd_cells $hier_name/packet_recover_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/packet_recover_int_mem_0
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
					] [get_bd_cells $hier_name/packet_recover_int_mem_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/rx_data_bram_0
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Write_Depth_A {256} \
					] [get_bd_cells $hier_name/rx_data_bram_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/rx_data_bram_ctrl_0
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/rx_data_bram_ctrl_0]

		
#connections
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem_0/BRAM_PORTA] [get_bd_intf_pins $hier_name/packet_recover_0/circular_bram_w]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem_0/BRAM_PORTB] [get_bd_intf_pins $hier_name/packet_recover_0/circular_bram_r]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_0/data_0] [get_bd_intf_pins $hier_name/packet_recover_0/data_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_0/data_1] [get_bd_intf_pins $hier_name/packet_recover_0/data_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_0/data_2] [get_bd_intf_pins $hier_name/packet_recover_0/data_2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_0/packet_bram_f] [get_bd_intf_pins $hier_name/rx_data_bram_0/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/rx_data_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins $hier_name/rx_data_bram_0/BRAM_PORTB]
connect_bd_net 	[get_bd_pins $hier_name/bus_receiver_0/wclk] \
				[get_bd_pins $hier_name/packet_recover_0/wclk]
				
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_0_BRAM_AXI] [get_bd_intf_pins $hier_name/rx_data_bram_ctrl_0/S_AXI]


connect_bd_net [get_bd_pins $hier_name/RX_0] [get_bd_pins $hier_name/bus_receiver_0/din]

#############################################
# receiver 1
#############################################

create_bd_cell -type ip -vlnv bdsound.com:user:bus_receiver:1.0 $hier_name/bus_receiver_1
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_receiver_1]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_recover:1.0 $hier_name/packet_recover_1
set_property -dict [list CONFIG.TRUE_BRAM {true}] [get_bd_cells $hier_name/packet_recover_1]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/packet_recover_int_mem_1
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
					] [get_bd_cells $hier_name/packet_recover_int_mem_1]
					
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/rx_data_bram_1
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Write_Depth_A {256} \
					] [get_bd_cells $hier_name/rx_data_bram_1]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/rx_data_bram_ctrl_1
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/rx_data_bram_ctrl_1]
		
		

connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem_1/BRAM_PORTA] [get_bd_intf_pins $hier_name/packet_recover_1/circular_bram_w]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem_1/BRAM_PORTB] [get_bd_intf_pins $hier_name/packet_recover_1/circular_bram_r]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_1/data_0] [get_bd_intf_pins $hier_name/packet_recover_1/data_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_1/data_1] [get_bd_intf_pins $hier_name/packet_recover_1/data_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_1/data_2] [get_bd_intf_pins $hier_name/packet_recover_1/data_2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_1/packet_bram_f] [get_bd_intf_pins $hier_name/rx_data_bram_1/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/rx_data_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins $hier_name/rx_data_bram_1/BRAM_PORTB]
connect_bd_net 	[get_bd_pins $hier_name/bus_receiver_1/wclk] \
				[get_bd_pins $hier_name/packet_recover_1/wclk]
				
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_1_BRAM_AXI] [get_bd_intf_pins $hier_name/rx_data_bram_ctrl_1/S_AXI]


connect_bd_net [get_bd_pins $hier_name/RX_1] [get_bd_pins $hier_name/bus_receiver_1/din]


#############################################
# receiver 2
#############################################

create_bd_cell -type ip -vlnv bdsound.com:user:bus_receiver:1.0 $hier_name/bus_receiver_2
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_receiver_2]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_recover:1.0 $hier_name/packet_recover_2
set_property -dict [list CONFIG.TRUE_BRAM {true}] [get_bd_cells $hier_name/packet_recover_2]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/packet_recover_int_mem_2
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
					] [get_bd_cells $hier_name/packet_recover_int_mem_2]
					
#external bram to the processor
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/rx_data_bram_2
set_property -dict [list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Write_Depth_A {256} \
					] [get_bd_cells $hier_name/rx_data_bram_2]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 $hier_name/rx_data_bram_ctrl_2
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells $hier_name/rx_data_bram_ctrl_2]
		
		
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem_2/BRAM_PORTA] [get_bd_intf_pins $hier_name/packet_recover_2/circular_bram_w]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem_2/BRAM_PORTB] [get_bd_intf_pins $hier_name/packet_recover_2/circular_bram_r]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_2/data_0] [get_bd_intf_pins $hier_name/packet_recover_2/data_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_2/data_1] [get_bd_intf_pins $hier_name/packet_recover_2/data_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_2/data_2] [get_bd_intf_pins $hier_name/packet_recover_2/data_2]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_2/packet_bram_f] [get_bd_intf_pins $hier_name/rx_data_bram_2/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/rx_data_bram_ctrl_2/BRAM_PORTA] [get_bd_intf_pins $hier_name/rx_data_bram_2/BRAM_PORTB]
connect_bd_net 	[get_bd_pins $hier_name/bus_receiver_2/wclk] \
				[get_bd_pins $hier_name/packet_recover_2/wclk]
				
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_2_BRAM_AXI] [get_bd_intf_pins $hier_name/rx_data_bram_ctrl_2/S_AXI]


connect_bd_net [get_bd_pins $hier_name/RX_2] [get_bd_pins $hier_name/bus_receiver_2/din]		
		
		
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/valid
set_property -dict [list CONFIG.CONST_VAL {1}] [get_bd_cells $hier_name/valid]	
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/mute
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells $hier_name/mute]	

	



for {set i 0} {$i < $bus_ch_num} {incr i} {
	connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_0/audio_$i] [get_bd_intf_pins $hier_name/audio_router/audio_0_in_$i]
	
	connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_2/audio_$i] [get_bd_intf_pins $hier_name/audio_router/audio_2_in_$i]
	connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_AUDIO_$i] [get_bd_intf_pins $hier_name/audio_router/audio_out_$i]
}

# Speaker from tv hub
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_1/audio_0] [get_bd_intf_pins $hier_name/audio_router/audio_1_in_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver_1/audio_1] [get_bd_intf_pins $hier_name/audio_router/audio_1_in_1]

connect_bd_net [get_bd_pins $hier_name/spk_0_from_usb] [get_bd_pins $hier_name/audio_router/audio_1_in_data_2]
connect_bd_net [get_bd_pins $hier_name/spk_1_from_usb] [get_bd_pins $hier_name/audio_router/audio_1_in_data_3]

#############################################
# transmitter
#############################################

#create and configure  ips
create_bd_cell -type ip -vlnv bdsound.com:user:bus_transmitter:1.0 $hier_name/bus_transmitter
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_transmitter]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_sender:1.0 $hier_name/packet_sender
set_property -dict [list CONFIG.PORT_1_TRUE_BRAM {true}] [get_bd_cells $hier_name/packet_sender]
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


connect_bd_net 	[get_bd_pins $hier_name/bus_transmitter/dout] \
				[get_bd_pins $hier_name/TX_0] \
				[get_bd_pins $hier_name/TX_1] \
				[get_bd_pins $hier_name/TX_2]
				

#############################################
# command manager
#############################################

#create and configure  ips
create_bd_cell -type ip -vlnv bdsound.com:user:comm_manager:1.0 $hier_name/comm_manager_0
create_bd_cell -type ip -vlnv bdsound.com:user:comm_manager:1.0 $hier_name/comm_manager_1
create_bd_cell -type ip -vlnv bdsound.com:user:comm_manager:1.0 $hier_name/comm_manager_2

#connections
connect_bd_intf_net [get_bd_intf_pins $hier_name/comm_manager_0/TX] [get_bd_intf_pins $hier_name/packet_sender/packet1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_0/packet] [get_bd_intf_pins $hier_name/comm_manager_0/RX]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_1/packet] [get_bd_intf_pins $hier_name/comm_manager_1/RX]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_2/packet] [get_bd_intf_pins $hier_name/comm_manager_2/RX]

connect_bd_net 	[get_bd_pins $hier_name/bus_receiver_0/locked] [get_bd_pins $hier_name/comm_manager_0/HUB_LOCKED]
connect_bd_net 	[get_bd_pins $hier_name/bus_receiver_1/locked] [get_bd_pins $hier_name/comm_manager_1/HUB_LOCKED]
connect_bd_net 	[get_bd_pins $hier_name/bus_receiver_2/locked] [get_bd_pins $hier_name/comm_manager_2/HUB_LOCKED]
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/COMM_0_AXI] [get_bd_intf_pins $hier_name/comm_manager_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/COMM_1_AXI] [get_bd_intf_pins $hier_name/comm_manager_1/S_AXI]
connect_bd_intf_net [get_bd_intf_pins $hier_name/COMM_2_AXI] [get_bd_intf_pins $hier_name/comm_manager_2/S_AXI]

connect_bd_intf_net [get_bd_intf_pins $hier_name/AUDIO_ROUTER_AXI] [get_bd_intf_pins $hier_name/audio_router/S_AXI]


connect_bd_net [get_bd_pins $hier_name/INTR_0] [get_bd_pins $hier_name/comm_manager_0/INTR]
connect_bd_net [get_bd_pins $hier_name/INTR_1] [get_bd_pins $hier_name/comm_manager_1/INTR]
connect_bd_net [get_bd_pins $hier_name/INTR_2] [get_bd_pins $hier_name/comm_manager_2/INTR]

#############################################
# clock and rst
#############################################





#clock
connect_bd_net 	[get_bd_pins $hier_name/clk_100M] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl_0/s_axi_aclk] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl_1/s_axi_aclk] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl_2/s_axi_aclk] \
				[get_bd_pins $hier_name/comm_manager_0/S_AXI_ACLK] \
				[get_bd_pins $hier_name/comm_manager_1/S_AXI_ACLK] \
				[get_bd_pins $hier_name/comm_manager_2/S_AXI_ACLK] \
				[get_bd_pins $hier_name/tx_data_bram_ctrl/s_axi_aclk] \
				[get_bd_pins $hier_name/audio_router/S_AXI_ACLK]

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_0] \
				[get_bd_pins $hier_name/bus_receiver_0/clk_0] \
				[get_bd_pins $hier_name/bus_receiver_1/clk_0] \
				[get_bd_pins $hier_name/bus_receiver_2/clk_0] \
				[get_bd_pins $hier_name/packet_recover_0/clk] \
				[get_bd_pins $hier_name/packet_recover_1/clk] \
				[get_bd_pins $hier_name/packet_recover_2/clk] \
				[get_bd_pins $hier_name/comm_manager_0/clk_rx] \
				[get_bd_pins $hier_name/comm_manager_1/clk_rx] \
				[get_bd_pins $hier_name/comm_manager_2/clk_rx]
				
connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_ext] \
				[get_bd_pins $hier_name/bus_transmitter/clk] \
				[get_bd_pins $hier_name/packet_sender/clk] \
				[get_bd_pins $hier_name/comm_manager_0/clk_tx] \
				[get_bd_pins $hier_name/comm_manager_1/clk_tx] \
				[get_bd_pins $hier_name/comm_manager_2/clk_tx] \
				[get_bd_pins $hier_name/audio_router/clk]
				
				
				
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_90] [get_bd_pins $hier_name/bus_receiver_0/clk_90]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_90] [get_bd_pins $hier_name/bus_receiver_1/clk_90]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_90] [get_bd_pins $hier_name/bus_receiver_2/clk_90]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_180] [get_bd_pins $hier_name/bus_receiver_0/clk_180]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_180] [get_bd_pins $hier_name/bus_receiver_1/clk_180]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_180] [get_bd_pins $hier_name/bus_receiver_2/clk_180]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_270] [get_bd_pins $hier_name/bus_receiver_0/clk_270]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_270] [get_bd_pins $hier_name/bus_receiver_1/clk_270]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_270] [get_bd_pins $hier_name/bus_receiver_2/clk_270]

#reset
connect_bd_net 	[get_bd_pins $hier_name/clk_100M_rst_n] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl_0/s_axi_aresetn] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl_1/s_axi_aresetn] \
				[get_bd_pins $hier_name/rx_data_bram_ctrl_2/s_axi_aresetn] \
				[get_bd_pins $hier_name/comm_manager_0/S_AXI_ARESETN] \
				[get_bd_pins $hier_name/comm_manager_1/S_AXI_ARESETN] \
				[get_bd_pins $hier_name/comm_manager_2/S_AXI_ARESETN] \
				[get_bd_pins $hier_name/tx_data_bram_ctrl/s_axi_aresetn] \
				[get_bd_pins $hier_name/audio_router/S_AXI_ARESETN]

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_rst_n] \
				[get_bd_pins $hier_name/bus_receiver_0/rst_n] \
				[get_bd_pins $hier_name/bus_receiver_1/rst_n] \
				[get_bd_pins $hier_name/bus_receiver_2/rst_n] \
				[get_bd_pins $hier_name/packet_recover_0/rst_n] \
				[get_bd_pins $hier_name/packet_recover_1/rst_n] \
				[get_bd_pins $hier_name/packet_recover_2/rst_n]

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_ext_rst_n] \
				[get_bd_pins $hier_name/bus_transmitter/rst_n] \
				[get_bd_pins $hier_name/packet_sender/rst_n] \
				[get_bd_pins $hier_name/audio_router/rst_n]
				
#enable
connect_bd_net 	[get_bd_pins $hier_name/comm_manager_0/ENABLE_RX] \
				[get_bd_pins $hier_name/packet_recover_0/enable] \
				[get_bd_pins $hier_name/bus_receiver_0/enable]
				
connect_bd_net 	[get_bd_pins $hier_name/comm_manager_1/ENABLE_RX] \
				[get_bd_pins $hier_name/packet_recover_1/enable] \
				[get_bd_pins $hier_name/bus_receiver_1/enable]
				
connect_bd_net 	[get_bd_pins $hier_name/comm_manager_2/ENABLE_RX] \
				[get_bd_pins $hier_name/packet_recover_2/enable] \
				[get_bd_pins $hier_name/bus_receiver_2/enable]
				

connect_bd_net 	[get_bd_pins tdm_hub/comm_manager_0/ENABLE_TX] \
				[get_bd_pins tdm_hub/bus_transmitter/enable] \
				[get_bd_pins $hier_name/packet_sender/enable]
				
connect_bd_net 	[get_bd_pins $hier_name/comm_manager_0/DIR] [get_bd_pins $hier_name/DIR_0]
connect_bd_net 	[get_bd_pins $hier_name/comm_manager_1/DIR] [get_bd_pins $hier_name/DIR_1]
connect_bd_net 	[get_bd_pins $hier_name/comm_manager_2/DIR] [get_bd_pins $hier_name/DIR_2]


connect_bd_net [get_bd_pins $hier_name/spk_0] [get_bd_pins $hier_name/bus_transmitter/audio_data_0]
connect_bd_net [get_bd_pins $hier_name/spk_1] [get_bd_pins $hier_name/bus_transmitter/audio_data_1]
connect_bd_net [get_bd_pins $hier_name/mic_to_usb] [get_bd_pins $hier_name/bus_transmitter/audio_data_2]

connect_bd_net 	[get_bd_pins $hier_name/valid/dout] \
				[get_bd_pins $hier_name/bus_transmitter/audio_valid_0] \
				[get_bd_pins $hier_name/bus_transmitter/audio_valid_1] \
				[get_bd_pins $hier_name/bus_transmitter/audio_valid_2]
				
connect_bd_net 	[get_bd_pins $hier_name/mute/dout] \
				[get_bd_pins $hier_name/bus_transmitter/audio_mute_0] \
				[get_bd_pins $hier_name/bus_transmitter/audio_mute_1] \
				[get_bd_pins $hier_name/bus_transmitter/audio_mute_2]






