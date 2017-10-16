#general ports
create_bd_pin -dir I $hier_name/clk_20_48M_int_0
create_bd_pin -dir I $hier_name/clk_20_48M_int_90
create_bd_pin -dir I $hier_name/clk_20_48M_int_180
create_bd_pin -dir I $hier_name/clk_20_48M_int_270
create_bd_pin -dir I $hier_name/clk_20_48M_int_lock
create_bd_pin -dir I $hier_name/clk_20_48M_int_rst_n
create_bd_pin -dir I $hier_name/clk_20_48M_ext_lock


create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 $hier_name/BUS_MIC_DATA_BRAM


create_bd_intf_pin -mode Master -vlnv bdsound.com:user:packet_handshake_port_rtl:1.0 $hier_name/RX_PACKET

for {set i 0}  {$i < $bus_ch_num} {incr i} {
	create_bd_intf_pin -mode Master -vlnv bdsound.com:user:general_audio_rtl:1.0 $hier_name/RX_AUDIO_$i	
}

create_bd_pin -dir I $hier_name/RX

create_bd_pin -dir O $hier_name/wclk_bus
create_bd_pin -dir O $hier_name/locked

#############################################
# receiver
#############################################

#create and configure  ips
create_bd_cell -type ip -vlnv bdsound.com:user:bus_receiver:1.0 $hier_name/bus_receiver
set_property -dict [list CONFIG.AUDIO_CHANNELS $bus_ch_num] [get_bd_cells $hier_name/bus_receiver]

create_bd_cell -type ip -vlnv bdsound.com:user:packet_recover:1.0 $hier_name/packet_recover
# set true bram to connect to a bram controller mode bram (to processor)
set_property -dict [list CONFIG.TRUE_BRAM {false}] [get_bd_cells $hier_name/packet_recover]

#internal memory needed by packet recover
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
					
#external bram to the processor
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 $hier_name/rx_data_bram

set_property -dict [list \
						CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
						CONFIG.use_bram_block {Stand_Alone} \
						CONFIG.Enable_32bit_Address {false} \
						CONFIG.Use_Byte_Write_Enable {false} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Byte_Size {9} \
						CONFIG.Operating_Mode_A {NO_CHANGE} \
						CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
						CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
						CONFIG.Use_RSTA_Pin {false} \
						CONFIG.Use_RSTB_Pin {false} \
						CONFIG.Port_B_Write_Rate {0} \
						CONFIG.Write_Width_A {8} \
						CONFIG.Write_Depth_A {1024} \
						CONFIG.Read_Width_A {8} \
						CONFIG.Write_Width_B {8} \
						CONFIG.Read_Width_B {8} \
					] [get_bd_cells $hier_name/rx_data_bram]
					


						

#connections
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem/BRAM_PORTA] [get_bd_intf_pins $hier_name/packet_recover/circular_bram_w]
connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover_int_mem/BRAM_PORTB] [get_bd_intf_pins $hier_name/packet_recover/circular_bram_r]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver/data_0] [get_bd_intf_pins $hier_name/packet_recover/data_0]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver/data_1] [get_bd_intf_pins $hier_name/packet_recover/data_1]
connect_bd_intf_net [get_bd_intf_pins $hier_name/bus_receiver/data_2] [get_bd_intf_pins $hier_name/packet_recover/data_2]


connect_bd_net 	[get_bd_pins $hier_name/bus_receiver/wclk] \
				[get_bd_pins $hier_name/packet_recover/wclk] \
				[get_bd_pins $hier_name/wclk_bus]
				


for {set i 0}  {$i < $bus_ch_num} {incr i} {		
	connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_AUDIO_$i] [get_bd_intf_pins $hier_name/bus_receiver/audio_$i]	
}

connect_bd_net [get_bd_pins $hier_name/RX] [get_bd_pins $hier_name/bus_receiver/din]

#############################################
# transmitter
#############################################







#############################################
# command manager
#############################################




#############################################
# clock and rst
#############################################

#clock

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_0] \
				[get_bd_pins $hier_name/bus_receiver/clk_0] \
				[get_bd_pins $hier_name/packet_recover/clk]

				
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_90] [get_bd_pins $hier_name/bus_receiver/clk_90]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_180] [get_bd_pins $hier_name/bus_receiver/clk_180]
connect_bd_net [get_bd_pins $hier_name/clk_20_48M_int_270] [get_bd_pins $hier_name/bus_receiver/clk_270]

#reset

connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_rst_n] \
				[get_bd_pins $hier_name/bus_receiver/rst_n] \
				[get_bd_pins $hier_name/packet_recover/rst_n]

				
#enable
connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_int_lock] \
				[get_bd_pins $hier_name/bus_receiver/enable]


connect_bd_net 	[get_bd_pins $hier_name/clk_20_48M_ext_lock] \
				[get_bd_pins $hier_name/packet_recover/enable]

connect_bd_net [get_bd_pins $hier_name/locked] [get_bd_pins $hier_name/bus_receiver/locked]
connect_bd_intf_net [get_bd_intf_pins $hier_name/RX_PACKET] [get_bd_intf_pins $hier_name/packet_recover/packet]

connect_bd_intf_net [get_bd_intf_pins $hier_name/packet_recover/packet_bram_s] [get_bd_intf_pins $hier_name/rx_data_bram/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins $hier_name/BUS_MIC_DATA_BRAM] [get_bd_intf_pins $hier_name/rx_data_bram/BRAM_PORTB]