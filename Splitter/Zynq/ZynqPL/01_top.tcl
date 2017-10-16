create_bd_design "splitter_design"


create_bd_port -dir O BUFFER_0_TX
create_bd_port -dir O BUFFER_1_TX
create_bd_port -dir O BUFFER_2_TX
create_bd_port -dir O BUFFER_3_TX
create_bd_port -dir O BUFFER_4_TX
create_bd_port -dir O BUFFER_5_TX

create_bd_port -dir I BUFFER_0_RX
create_bd_port -dir I BUFFER_1_RX
create_bd_port -dir I BUFFER_2_RX
create_bd_port -dir I BUFFER_3_RX
create_bd_port -dir I BUFFER_4_RX
create_bd_port -dir I BUFFER_5_RX

create_bd_port -dir O PLL_SPI_SCLK
create_bd_port -dir O PLL_SPI_MOSI
create_bd_port -dir O PLL_SPI_CS

create_bd_port -dir I MCLK
create_bd_port -dir O PLL_WCLK
create_bd_port -dir I PLL_LOCK

create_bd_port -dir O BUFFER_0_DIR
create_bd_port -dir O BUFFER_1_DIR
create_bd_port -dir O BUFFER_2_DIR
create_bd_port -dir O BUFFER_3_DIR
#create_bd_port -dir O LED_0_G
#create_bd_port -dir O LED_1_G
#create_bd_port -dir O LED_2_G
#create_bd_port -dir O LED_3_G

create_bd_port -dir O -from 3 -to 0 LEDS_OUT

set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
	
set tdm_hub_0 [create_bd_cell -type hier tdm_hub_0]
set tdm_hub_1 [create_bd_cell -type hier tdm_hub_1]
set tdm_mic_0 [create_bd_cell -type hier tdm_mic_0]
set tdm_mic_1 [create_bd_cell -type hier tdm_mic_1]
set clock_gen [create_bd_cell -type hier clock_gen]
#set audio_mems [create_bd_cell -type hier audio_mems]

#create and configure processing system
set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0 ]
set_property -dict [list \
						CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
						CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
						CONFIG.PCW_IRQ_F2P_INTR {1} \
						CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J64M16 JT-125G} \
						CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
						CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
						CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
						CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
						CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
						CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
						CONFIG.PCW_GPIO_EMIO_GPIO_IO {4} \
					] [get_bd_cells processing_system7_0]

	create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
	connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins processing_system7_0/SPI0_SS_I]
	connect_bd_intf_net [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
	connect_bd_intf_net [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]					
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 intr_concat
set_property -dict [list \
						CONFIG.NUM_PORTS {1} \
						CONFIG.IN0_WIDTH.VALUE_SRC USER \
						CONFIG.IN0_WIDTH {2} \
					] [get_bd_cells intr_concat]

					
#create and configure interconnect
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0		
set_property -dict [list CONFIG.NUM_MI {6}] [get_bd_cells axi_interconnect_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M

create_bd_cell -type ip -vlnv bdsound.com:user:audio_router:1.0 audio_router
set_property -dict [list CONFIG.INTERFACE_NUMBER {3}] [get_bd_cells audio_router]

create_bd_cell -type ip -vlnv xilinx.com:user:version:1.0 version_ip
set localVersion $version
scan $version %d localVersion
set_property -dict [list CONFIG.VERSION_NUM $localVersion] [get_bd_cells version_ip]


#apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_pins axi_interconnect_0/ACLK]

connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]


create_bd_cell -type ip -vlnv bdsound.com:user:bus_router_mic_pod_hub:1.0 bus_router_mic_pod_hub

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 bus_router_mem

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
					] [get_bd_cells bus_router_mem]


#generate low level block	

source ./02_clock_gen.tcl

set hier_name			tdm_hub_1
set hier_is_hub_type 	false
source ./02_bus_mic.tcl

set hier_name			tdm_mic_0
set hier_is_hub_type 	false
source ./02_bus_mic.tcl

set hier_name			tdm_mic_1
set hier_is_hub_type 	false
source ./02_bus_mic.tcl

set hier_name			tdm_hub_0
set hier_is_hub_type 	false
source ./02_bus_hub.tcl



# #connect 100M clock


connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]

connect_bd_net [get_bd_pins rst_ps7_0_100M/interconnect_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]

connect_bd_net 	[get_bd_pins processing_system7_0/FCLK_CLK0] \
				[get_bd_pins rst_ps7_0_100M/slowest_sync_clk] \
				[get_bd_pins axi_interconnect_0/ACLK] \
				[get_bd_pins axi_interconnect_0/S00_ACLK] \
				[get_bd_pins axi_interconnect_0/M00_ACLK] \
				[get_bd_pins axi_interconnect_0/M01_ACLK] \
				[get_bd_pins axi_interconnect_0/M02_ACLK] \
				[get_bd_pins axi_interconnect_0/M03_ACLK] \
				[get_bd_pins axi_interconnect_0/M04_ACLK] \
				[get_bd_pins axi_interconnect_0/M05_ACLK] \
				[get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
				[get_bd_pins clock_gen/clk_100M] \
				[get_bd_pins tdm_hub_0/clk_100M] \
				[get_bd_pins bus_router_mic_pod_hub/S_AXI_ACLK] \
				[get_bd_pins audio_router/S_AXI_ACLK] \
				[get_bd_pins version_ip/S_AXI_ACLK]
				
# #connect 20.48M clock 
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_0] \
				[get_bd_pins tdm_hub_0/clk_20_48M_int_0] \
				[get_bd_pins tdm_hub_1/clk_20_48M_int_0] \
				[get_bd_pins tdm_mic_0/clk_20_48M_int_0] \
				[get_bd_pins tdm_mic_1/clk_20_48M_int_0]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_90] \
				[get_bd_pins tdm_hub_0/clk_20_48M_int_90] \
				[get_bd_pins tdm_hub_1/clk_20_48M_int_90] \
				[get_bd_pins tdm_mic_0/clk_20_48M_int_90] \
				[get_bd_pins tdm_mic_1/clk_20_48M_int_90]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_180] \
				[get_bd_pins tdm_hub_0/clk_20_48M_int_180] \
				[get_bd_pins tdm_hub_1/clk_20_48M_int_180] \
				[get_bd_pins tdm_mic_0/clk_20_48M_int_180] \
				[get_bd_pins tdm_mic_1/clk_20_48M_int_180]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_270] \
				[get_bd_pins tdm_hub_0/clk_20_48M_int_270] \
				[get_bd_pins tdm_hub_1/clk_20_48M_int_270] \
				[get_bd_pins tdm_mic_0/clk_20_48M_int_270] \
				[get_bd_pins tdm_mic_1/clk_20_48M_int_270]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_ext] \
				[get_bd_pins tdm_hub_0/clk_20_48M_ext] \
				[get_bd_pins audio_router/clk]



			
#connect 100M reset
connect_bd_net 	[get_bd_pins processing_system7_0/FCLK_RESET0_N] \
				[get_bd_pins clock_gen/ext_rst_n] 	
				
connect_bd_net 	[get_bd_pins rst_ps7_0_100M/peripheral_aresetn] \
				[get_bd_pins axi_interconnect_0/S00_ARESETN] \
				[get_bd_pins axi_interconnect_0/M00_ARESETN] \
				[get_bd_pins axi_interconnect_0/M01_ARESETN] \
				[get_bd_pins axi_interconnect_0/M02_ARESETN] \
				[get_bd_pins axi_interconnect_0/M03_ARESETN] \
				[get_bd_pins axi_interconnect_0/M04_ARESETN] \
				[get_bd_pins axi_interconnect_0/M05_ARESETN] \
				[get_bd_pins tdm_hub_0/clk_100M_rst_n] \
				[get_bd_pins bus_router_mic_pod_hub/S_AXI_ARESETN] \
				[get_bd_pins audio_router/S_AXI_ARESETN] \
				[get_bd_pins version_ip/S_AXI_ARESETN]
				



				
#connect 20.48M reset and other signals 				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_rst_n] \
				[get_bd_pins tdm_hub_0/clk_20_48M_int_rst_n] \
				[get_bd_pins tdm_hub_1/clk_20_48M_int_rst_n] \
				[get_bd_pins tdm_mic_0/clk_20_48M_int_rst_n] \
				[get_bd_pins tdm_mic_1/clk_20_48M_int_rst_n] 	
				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_ext_rst_n] \
				[get_bd_pins tdm_hub_0/clk_20_48M_ext_rst_n] \
				[get_bd_pins tdm_hub_1/clk_20_48M_ext_rst_n] \
				[get_bd_pins tdm_mic_0/clk_20_48M_ext_rst_n] \
				[get_bd_pins tdm_mic_1/clk_20_48M_ext_rst_n] \
				[get_bd_pins audio_router/rst_n] 
		

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_lock] \
				[get_bd_pins tdm_hub_0/clk_20_48M_int_lock] \
				[get_bd_pins tdm_hub_1/clk_20_48M_int_lock] \
				[get_bd_pins tdm_mic_0/clk_20_48M_int_lock] \
				[get_bd_pins tdm_mic_1/clk_20_48M_int_lock]		

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_ext_lock] \
				[get_bd_pins tdm_hub_0/clk_20_48M_ext_lock] \
				[get_bd_pins tdm_hub_1/clk_20_48M_ext_lock] \
				[get_bd_pins tdm_mic_0/clk_20_48M_ext_lock] \
				[get_bd_pins tdm_mic_1/clk_20_48M_ext_lock]
				
connect_bd_net 	[get_bd_pins clock_gen/wclk_bus] \
				[get_bd_pins tdm_hub_0/wclk_ext] \
				[get_bd_pins audio_router/wclk]
#connect axi
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins tdm_hub_0/COMM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins tdm_hub_0/TX_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins tdm_hub_0/RX_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins bus_router_mic_pod_hub/S_AXI] 
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins audio_router/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M05_AXI] [get_bd_intf_pins version_ip/S_AXI]
#connect interrupt
connect_bd_net [get_bd_pins tdm_hub_0/INTR] [get_bd_pins intr_concat/In0]
connect_bd_net [get_bd_pins intr_concat/dout] [get_bd_pins processing_system7_0/IRQ_F2P]


# connect_bd_net 	[get_bd_ports BUS0_RX] \
				# [get_bd_pins bus_router/RX_0]

# connect_bd_net 	[get_bd_ports BUS1_RX] \
				# [get_bd_pins bus_router/RX_1]
				
# connect_bd_net [get_bd_pins tdm_hub/TX] [get_bd_pins bus_router/TX_hub]

# connect_bd_net [get_bd_ports BUS0_TX] [get_bd_pins bus_router/TX_0_out]
# connect_bd_net [get_bd_ports BUS1_TX] [get_bd_pins bus_router/TX_1_out]


connect_bd_net [get_bd_ports PLL_SPI_SCLK] [get_bd_pins processing_system7_0/SPI0_SCLK_O]
connect_bd_net [get_bd_ports PLL_SPI_MOSI] [get_bd_pins processing_system7_0/SPI0_MOSI_O]
connect_bd_net [get_bd_ports PLL_SPI_CS] [get_bd_pins processing_system7_0/SPI0_SS_O]

connect_bd_net [get_bd_ports MCLK] [get_bd_pins clock_gen/clk_16_384M]



connect_bd_net [get_bd_ports LEDS_OUT] [get_bd_pins processing_system7_0/GPIO_O]



				
	

connect_bd_net [get_bd_ports PLL_WCLK] [get_bd_pins tdm_hub_0/wclk_bus]
# connect_bd_net [get_bd_pins tdm_hub/RX] [get_bd_pins bus_router/RX_hub_out]
# connect_bd_net [get_bd_pins tdm_mic/RX] [get_bd_pins bus_router/RX_mic_out]

connect_bd_net [get_bd_pins tdm_hub_0/RX] [get_bd_pins bus_router_mic_pod_hub/RX_hub_0]
connect_bd_net [get_bd_pins tdm_hub_1/RX] [get_bd_pins bus_router_mic_pod_hub/RX_hub_1]
connect_bd_net [get_bd_pins tdm_hub_0/TX] [get_bd_pins bus_router_mic_pod_hub/TX_hub_0]

connect_bd_net [get_bd_ports BUFFER_0_RX] [get_bd_pins bus_router_mic_pod_hub/RX_RJ_0]
connect_bd_net [get_bd_ports BUFFER_1_RX] [get_bd_pins bus_router_mic_pod_hub/RX_RJ_1]
connect_bd_net [get_bd_ports BUFFER_2_RX] [get_bd_pins bus_router_mic_pod_hub/RX_RJ_2]
connect_bd_net [get_bd_ports BUFFER_3_RX] [get_bd_pins bus_router_mic_pod_hub/RX_RJ_3]
connect_bd_net [get_bd_ports BUFFER_4_RX] [get_bd_pins tdm_mic_0/RX]
connect_bd_net [get_bd_ports BUFFER_5_RX] [get_bd_pins tdm_mic_1/RX]

connect_bd_net [get_bd_ports BUFFER_0_TX] [get_bd_pins bus_router_mic_pod_hub/TX_RJ_0]
connect_bd_net [get_bd_ports BUFFER_1_TX] [get_bd_pins bus_router_mic_pod_hub/TX_RJ_1]
connect_bd_net [get_bd_ports BUFFER_2_TX] [get_bd_pins bus_router_mic_pod_hub/TX_RJ_2]
connect_bd_net [get_bd_ports BUFFER_3_TX] [get_bd_pins bus_router_mic_pod_hub/TX_RJ_3]
connect_bd_net [get_bd_ports BUFFER_0_DIR] [get_bd_pins bus_router_mic_pod_hub/DIR_RJ_0]
connect_bd_net [get_bd_ports BUFFER_1_DIR] [get_bd_pins bus_router_mic_pod_hub/DIR_RJ_1]
connect_bd_net [get_bd_ports BUFFER_2_DIR] [get_bd_pins bus_router_mic_pod_hub/DIR_RJ_2]
connect_bd_net [get_bd_ports BUFFER_3_DIR] [get_bd_pins bus_router_mic_pod_hub/DIR_RJ_3]
connect_bd_net [get_bd_ports BUFFER_4_TX] [get_bd_pins bus_router_mic_pod_hub/TX_CC_0]
connect_bd_net [get_bd_ports BUFFER_5_TX] [get_bd_pins bus_router_mic_pod_hub/TX_CC_1]


connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_0] [get_bd_intf_pins audio_router/audio_0_in_0]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_1] [get_bd_intf_pins audio_router/audio_0_in_1]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_2] [get_bd_intf_pins audio_router/audio_0_in_2]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_3] [get_bd_intf_pins audio_router/audio_0_in_3]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_4] [get_bd_intf_pins audio_router/audio_0_in_4]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_5] [get_bd_intf_pins audio_router/audio_0_in_5]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_6] [get_bd_intf_pins audio_router/audio_0_in_6]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_7] [get_bd_intf_pins audio_router/audio_0_in_7]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_8] [get_bd_intf_pins audio_router/audio_0_in_8]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_9] [get_bd_intf_pins audio_router/audio_0_in_9]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_10] [get_bd_intf_pins audio_router/audio_0_in_10]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_11] [get_bd_intf_pins audio_router/audio_0_in_11]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_12] [get_bd_intf_pins audio_router/audio_0_in_12]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_13] [get_bd_intf_pins audio_router/audio_0_in_13]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_AUDIO_14] [get_bd_intf_pins audio_router/audio_0_in_14]

connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_0] [get_bd_intf_pins audio_router/audio_1_in_0]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_1] [get_bd_intf_pins audio_router/audio_1_in_1]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_2] [get_bd_intf_pins audio_router/audio_1_in_2]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_3] [get_bd_intf_pins audio_router/audio_1_in_3]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_4] [get_bd_intf_pins audio_router/audio_1_in_4]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_5] [get_bd_intf_pins audio_router/audio_1_in_5]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_6] [get_bd_intf_pins audio_router/audio_1_in_6]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_7] [get_bd_intf_pins audio_router/audio_1_in_7]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_8] [get_bd_intf_pins audio_router/audio_1_in_8]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_9] [get_bd_intf_pins audio_router/audio_1_in_9]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_10] [get_bd_intf_pins audio_router/audio_1_in_10]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_11] [get_bd_intf_pins audio_router/audio_1_in_11]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_12] [get_bd_intf_pins audio_router/audio_1_in_12]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_13] [get_bd_intf_pins audio_router/audio_1_in_13]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_AUDIO_14] [get_bd_intf_pins audio_router/audio_1_in_14]

connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_0] [get_bd_intf_pins audio_router/audio_2_in_0]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_1] [get_bd_intf_pins audio_router/audio_2_in_1]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_2] [get_bd_intf_pins audio_router/audio_2_in_2]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_3] [get_bd_intf_pins audio_router/audio_2_in_3]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_4] [get_bd_intf_pins audio_router/audio_2_in_4]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_5] [get_bd_intf_pins audio_router/audio_2_in_5]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_6] [get_bd_intf_pins audio_router/audio_2_in_6]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_7] [get_bd_intf_pins audio_router/audio_2_in_7]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_8] [get_bd_intf_pins audio_router/audio_2_in_8]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_9] [get_bd_intf_pins audio_router/audio_2_in_9]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_10] [get_bd_intf_pins audio_router/audio_2_in_10]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_11] [get_bd_intf_pins audio_router/audio_2_in_11]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_12] [get_bd_intf_pins audio_router/audio_2_in_12]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_13] [get_bd_intf_pins audio_router/audio_2_in_13]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_AUDIO_14] [get_bd_intf_pins audio_router/audio_2_in_14]

connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_0] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_0]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_1] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_1]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_2] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_2]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_3] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_3]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_4] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_4]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_5] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_5]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_6] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_6]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_7] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_7]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_8] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_8]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_9] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_9]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_10] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_10]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_11] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_11]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_12] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_12]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_13] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_13]
connect_bd_intf_net [get_bd_intf_pins audio_router/audio_out_14] [get_bd_intf_pins tdm_hub_0/TX_AUDIO_14]


connect_bd_intf_net [get_bd_intf_pins audio_router/int_bram_w] [get_bd_intf_pins bus_router_mem/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins audio_router/int_bram_r] [get_bd_intf_pins bus_router_mem/BRAM_PORTB]


connect_bd_intf_net [get_bd_intf_pins tdm_hub_0/BUS_MIC_DATA_BRAM_0] [get_bd_intf_pins tdm_mic_0/BUS_MIC_DATA_BRAM]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_0/BUS_MIC_DATA_BRAM_1] [get_bd_intf_pins tdm_mic_1/BUS_MIC_DATA_BRAM]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_0/BUS_HUB_DATA_BRAM_1] [get_bd_intf_pins tdm_hub_1/BUS_MIC_DATA_BRAM]
connect_bd_net [get_bd_pins tdm_mic_0/locked] [get_bd_pins tdm_hub_0/mic_0_locked] 
connect_bd_net [get_bd_pins tdm_mic_1/locked] [get_bd_pins tdm_hub_0/mic_1_locked] 
connect_bd_net [get_bd_pins tdm_hub_1/locked] [get_bd_pins tdm_hub_0/hub_1_locked] 

connect_bd_intf_net [get_bd_intf_pins tdm_mic_0/RX_PACKET] [get_bd_intf_pins tdm_hub_0/MIC_PACKET_0]
connect_bd_intf_net [get_bd_intf_pins tdm_mic_1/RX_PACKET] [get_bd_intf_pins tdm_hub_0/MIC_PACKET_1]
connect_bd_intf_net [get_bd_intf_pins tdm_hub_1/RX_PACKET] [get_bd_intf_pins tdm_hub_0/HUB_PACKET_1]











