create_bd_design "table_hub_design"

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_STM
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_CMD
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_DBG
create_bd_port -dir O -from 1 -to 0 GPO

create_bd_port -dir I BUS_MIC_RX
create_bd_port -dir O BUS_MIC_TX
create_bd_port -dir O BUS_HUB_0_DIR
create_bd_port -dir I BUS_HUB_0_RX
create_bd_port -dir O BUS_HUB_0_TX
create_bd_port -dir O BUS_HUB_1_DIR
create_bd_port -dir I BUS_HUB_1_RX
create_bd_port -dir O BUS_HUB_1_TX

create_bd_port -dir O AES3_1_TX
create_bd_port -dir O AES3_2_TX
create_bd_port -dir O I2S_0_SCK
create_bd_port -dir O I2S_0_WS
create_bd_port -dir O I2S_0_SDO
create_bd_port -dir I I2S_0_SDI

create_bd_port -dir I I2S_USB_SCK
create_bd_port -dir I I2S_USB_WS
create_bd_port -dir I I2S_USB_SD_IN
create_bd_port -dir O I2S_USB_SD_OUT

create_bd_port -dir O PLL_MCLK

set tdm_hub [create_bd_cell -type hier tdm_hub]
set clock_gen [create_bd_cell -type hier clock_gen]
set audio [create_bd_cell -type hier audio]
set usb [create_bd_cell -type hier usb]
#create and configure processing system
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
set_property -dict [list 	CONFIG.PCW_USE_M_AXI_GP0 {1} \
							CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
							CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
							CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
							CONFIG.PCW_UART0_UART0_IO {EMIO} \
							CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
							CONFIG.PCW_UART1_UART1_IO {EMIO} \
							CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
							CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
							CONFIG.PCW_IRQ_F2P_INTR {1} \
							CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
							CONFIG.PCW_GPIO_EMIO_GPIO_IO {2} \
					] [get_bd_cells processing_system7_0]

					
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 intr_concat

set_property -dict [list \
						CONFIG.NUM_PORTS {6} \
						CONFIG.IN0_WIDTH.VALUE_SRC USER \
						CONFIG.IN0_WIDTH {2} \
						CONFIG.IN1_WIDTH.VALUE_SRC USER \
						CONFIG.IN1_WIDTH {2} \
						CONFIG.IN2_WIDTH.VALUE_SRC USER \
						CONFIG.IN2_WIDTH {2} \
						CONFIG.IN3_WIDTH.VALUE_SRC USER \
						CONFIG.IN3_WIDTH {1} \
						CONFIG.IN4_WIDTH.VALUE_SRC USER \
						CONFIG.IN4_WIDTH {1} \
						CONFIG.IN5_WIDTH.VALUE_SRC USER \
						CONFIG.IN5_WIDTH {1} \
					] [get_bd_cells intr_concat]

					
#create and configure interconnect
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0		
set_property -dict [list CONFIG.NUM_MI {15}] [get_bd_cells axi_interconnect_0]

create_bd_cell -type ip -vlnv xilinx.com:user:version:1.0 version_ip
# set localVersion $version
# scan $version %d localVersion
set_property -dict [list CONFIG.VERSION_NUM $version] [get_bd_cells version_ip]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 uart_stm
set_property -dict [list \
					CONFIG.C_BAUDRATE {115200} \
					CONFIG.PARITY {Even} CONFIG.C_USE_PARITY {1} \
				] [get_bd_cells uart_stm]
#apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_pins axi_interconnect_0/ACLK]

connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

#generate low level block			
source ./02_clock_gen.tcl

set hier_name			audio
source ./02_audio.tcl

set hier_name			tdm_hub
set hier_is_hub_type 	true
source ./02_bus.tcl

set hier_name			usb
source ./02_usb.tcl

#connect 100M clock
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
				[get_bd_pins axi_interconnect_0/M06_ACLK] \
				[get_bd_pins axi_interconnect_0/M07_ACLK] \
				[get_bd_pins axi_interconnect_0/M08_ACLK] \
				[get_bd_pins axi_interconnect_0/M09_ACLK] \
				[get_bd_pins axi_interconnect_0/M10_ACLK] \
				[get_bd_pins axi_interconnect_0/M11_ACLK] \
				[get_bd_pins axi_interconnect_0/M12_ACLK] \
				[get_bd_pins axi_interconnect_0/M13_ACLK] \
				[get_bd_pins axi_interconnect_0/M14_ACLK] \
				[get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
				[get_bd_pins clock_gen/clk_100M] \
				[get_bd_pins tdm_hub/clk_100M] \
				[get_bd_pins uart_stm/s_axi_aclk] \
				[get_bd_pins audio/clk_100M] \
				[get_bd_pins version_ip/S_AXI_ACLK] \
				[get_bd_pins usb/clk_100M]
				
#connect 20.48M clock 
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_0] \
				[get_bd_pins tdm_hub/clk_20_48M_int_0] \
				[get_bd_pins tdm_hub/clk_20_48M_ext]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_90] \
				[get_bd_pins tdm_hub/clk_20_48M_int_90] 

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_180] \
				[get_bd_pins tdm_hub/clk_20_48M_int_180]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_270] \
				[get_bd_pins tdm_hub/clk_20_48M_int_270]
				


			
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
				[get_bd_pins axi_interconnect_0/M06_ARESETN] \
				[get_bd_pins axi_interconnect_0/M07_ARESETN] \
				[get_bd_pins axi_interconnect_0/M08_ARESETN] \
				[get_bd_pins axi_interconnect_0/M09_ARESETN] \
				[get_bd_pins axi_interconnect_0/M10_ARESETN] \
				[get_bd_pins axi_interconnect_0/M11_ARESETN] \
				[get_bd_pins axi_interconnect_0/M12_ARESETN] \
				[get_bd_pins axi_interconnect_0/M13_ARESETN] \
				[get_bd_pins axi_interconnect_0/M14_ARESETN] \
				[get_bd_pins tdm_hub/clk_100M_rst_n] \
				[get_bd_pins uart_stm/s_axi_aresetn] \
				[get_bd_pins audio/clk_100M_rst_n] \
				[get_bd_pins version_ip/S_AXI_ARESETN] \
				[get_bd_pins usb/clk_100M_rst_n]
				
				
connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M] \
				[get_bd_pins audio/clk_16_384M] \
				[get_bd_ports PLL_MCLK]
				
connect_bd_net 	[get_bd_pins clock_gen/i2s_wclk] \
				[get_bd_pins audio/i2s_lrclk] \
				[get_bd_ports I2S_0_WS]
				
connect_bd_net 	[get_bd_pins clock_gen/i2s_bclk] \
				[get_bd_pins audio/i2s_bclk] \
				[get_bd_ports I2S_0_SCK]
	
#connect 20.48M reset and other signals 				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_rst_n] \
				[get_bd_pins tdm_hub/clk_20_48M_int_rst_n] \
				[get_bd_pins tdm_hub/clk_20_48M_ext_rst_n]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M_rst_n] \
				[get_bd_pins audio/clk_16_384M_rst_n] \
				
				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_lock] \
				[get_bd_pins tdm_hub/clk_20_48M_int_lock] \
				[get_bd_pins tdm_hub/clk_20_48M_ext_lock]
				

				
connect_bd_net 	[get_bd_pins clock_gen/wclk] \
				[get_bd_pins tdm_hub/wclk_ext] \
				[get_bd_pins audio/wclk]


		
#connect axi
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins tdm_hub/COMM_0_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins tdm_hub/COMM_1_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins tdm_hub/COMM_2_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins tdm_hub/TX_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins tdm_hub/RX_0_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M05_AXI] [get_bd_intf_pins tdm_hub/RX_1_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M06_AXI] [get_bd_intf_pins tdm_hub/RX_2_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M07_AXI] [get_bd_intf_pins tdm_hub/AUDIO_ROUTER_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M08_AXI] [get_bd_intf_pins uart_stm/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M09_AXI] [get_bd_intf_pins audio/AXI_REG_TO_PS]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M10_AXI] [get_bd_intf_pins audio/AXI_REG_FROM_PS]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M11_AXI] [get_bd_intf_pins audio/AXI_BRAM_TO_PS]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M12_AXI] [get_bd_intf_pins audio/AXI_BRAM_FROM_PS]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M13_AXI] [get_bd_intf_pins version_ip/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M14_AXI] [get_bd_intf_pins audio/AXI_GAIN_SPK]

#connect interrupt
connect_bd_net [get_bd_pins tdm_hub/INTR_0] [get_bd_pins intr_concat/In0]
connect_bd_net [get_bd_pins tdm_hub/INTR_1] [get_bd_pins intr_concat/In1]
connect_bd_net [get_bd_pins tdm_hub/INTR_2] [get_bd_pins intr_concat/In2]
connect_bd_net [get_bd_pins uart_stm/interrupt] [get_bd_pins intr_concat/In3]
connect_bd_net [get_bd_pins audio/audio_to_ps_intr] [get_bd_pins intr_concat/In4]
connect_bd_net [get_bd_pins audio/audio_from_ps_intr] [get_bd_pins intr_concat/In5]
connect_bd_net [get_bd_pins intr_concat/dout] [get_bd_pins processing_system7_0/IRQ_F2P]


connect_bd_net [get_bd_ports BUS_HUB_0_TX] [get_bd_pins tdm_hub/TX_0]
connect_bd_net [get_bd_ports BUS_HUB_0_RX] [get_bd_pins tdm_hub/RX_0]
connect_bd_net [get_bd_ports BUS_HUB_0_DIR] [get_bd_pins tdm_hub/DIR_0]

connect_bd_net [get_bd_ports BUS_HUB_1_TX] [get_bd_pins tdm_hub/TX_1]
connect_bd_net [get_bd_ports BUS_HUB_1_RX] [get_bd_pins tdm_hub/RX_1]
connect_bd_net [get_bd_ports BUS_HUB_1_DIR] [get_bd_pins tdm_hub/DIR_1]

connect_bd_net [get_bd_ports BUS_MIC_TX] [get_bd_pins tdm_hub/TX_2]
connect_bd_net [get_bd_ports BUS_MIC_RX] [get_bd_pins tdm_hub/RX_2]




connect_bd_intf_net [get_bd_intf_pins uart_stm/UART] [get_bd_intf_ports UART_STM]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/UART_1] [get_bd_intf_ports UART_DBG]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/UART_0] [get_bd_intf_ports UART_CMD]


connect_bd_net [get_bd_ports GPO] [get_bd_pins processing_system7_0/GPIO_O]

connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_0] [get_bd_intf_pins audio/audio_from_bus_0]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_1] [get_bd_intf_pins audio/audio_from_bus_1]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_2] [get_bd_intf_pins audio/audio_from_bus_2]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_3] [get_bd_intf_pins audio/audio_from_bus_3]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_4] [get_bd_intf_pins audio/audio_from_bus_4]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_5] [get_bd_intf_pins audio/audio_from_bus_5]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_6] [get_bd_intf_pins audio/audio_from_bus_6]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_7] [get_bd_intf_pins audio/audio_from_bus_7]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_8] [get_bd_intf_pins audio/audio_from_bus_8]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_9] [get_bd_intf_pins audio/audio_from_bus_9]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_10] [get_bd_intf_pins audio/audio_from_bus_10]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_11] [get_bd_intf_pins audio/audio_from_bus_11]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_12] [get_bd_intf_pins audio/audio_from_bus_12]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_13] [get_bd_intf_pins audio/audio_from_bus_13]
connect_bd_intf_net [get_bd_intf_pins tdm_hub/RX_AUDIO_14] [get_bd_intf_pins audio/audio_from_bus_14]

connect_bd_net [get_bd_ports I2S_0_SDO] [get_bd_pins audio/i2s_dout]

connect_bd_net 	[get_bd_pins audio/aes_dout] \
				[get_bd_ports AES3_2_TX] \
				[get_bd_ports AES3_1_TX]
				
connect_bd_net 	[get_bd_pins audio/spk_0] [get_bd_pins tdm_hub/spk_0] 
				
connect_bd_net 	[get_bd_pins audio/spk_1] [get_bd_pins tdm_hub/spk_1]

connect_bd_net [get_bd_ports I2S_USB_WS] [get_bd_pins usb/I2S_USB_WS]
connect_bd_net [get_bd_ports I2S_USB_SD_IN] [get_bd_pins usb/I2S_USB_SD_IN]
connect_bd_net [get_bd_ports I2S_USB_SCK] [get_bd_pins usb/I2S_USB_SCK]
connect_bd_net [get_bd_ports I2S_USB_SD_OUT] [get_bd_pins usb/I2S_USB_SD_OUT]

connect_bd_net [get_bd_pins usb/spk_0_from_usb] [get_bd_pins tdm_hub/spk_0_from_usb]
connect_bd_net [get_bd_pins tdm_hub/spk_1_from_usb] [get_bd_pins usb/spk_1_from_usb]

connect_bd_net 	[get_bd_pins audio/mic_to_usb] \
				[get_bd_pins usb/mic_to_usb] \
				[get_bd_pins tdm_hub/mic_to_usb]