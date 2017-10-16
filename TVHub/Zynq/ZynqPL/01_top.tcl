create_bd_design "tv_hub_design"

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_STM
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_CMD
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_DBG
create_bd_port -dir O -from 1 -to 0 GPO


create_bd_port -dir O BUS_HUB_0_DIR
create_bd_port -dir I BUS_HUB_0_RX
create_bd_port -dir O BUS_HUB_0_TX


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

create_bd_port -dir I PLL_MCLK

create_bd_port -dir O PLL_SPI_SCLK
create_bd_port -dir O PLL_SPI_MOSI
create_bd_port -dir O PLL_SPI_CS
create_bd_port -dir O PLL_WCLK

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
							CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
					] [get_bd_cells processing_system7_0]

				
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 intr_concat
set_property -dict [list \
						CONFIG.NUM_PORTS {3} \
						CONFIG.IN0_WIDTH.VALUE_SRC USER \
						CONFIG.IN0_WIDTH {2} \
						CONFIG.IN1_WIDTH.VALUE_SRC USER \
						CONFIG.IN1_WIDTH {1} \
						CONFIG.IN2_WIDTH.VALUE_SRC USER \
						CONFIG.IN2_WIDTH {1} \
					] [get_bd_cells intr_concat]

					
#create and configure interconnect
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0		
set_property -dict [list CONFIG.NUM_MI {7}] [get_bd_cells axi_interconnect_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 pll_spi
set_property -dict [list \
						CONFIG.C_USE_STARTUP {0} \
						CONFIG.FIFO_INCLUDED {0} \
						CONFIG.C_USE_STARTUP_INT {0} \
						CONFIG.C_FIFO_DEPTH {0} \
						CONFIG.Multiples16 {2} \
					] [get_bd_cells pll_spi]
					
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
set clock_gen [create_bd_cell -type hier clock_gen]		
source ./02_clock_gen.tcl

set audio [create_bd_cell -type hier audio]
set hier_name			audio
source ./02_audio.tcl

set tdm_hub [create_bd_cell -type hier tdm_hub]
set hier_name			tdm_hub
source ./02_bus.tcl


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
				[get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
				[get_bd_pins clock_gen/clk_100M] \
				[get_bd_pins tdm_hub/clk_100M] \
				[get_bd_pins uart_stm/s_axi_aclk] \
				[get_bd_pins audio/clk_100M] \
				[get_bd_pins version_ip/S_AXI_ACLK] \
				[get_bd_pins pll_spi/ext_spi_clk] \
				[get_bd_pins pll_spi/s_axi_aclk]
				

#connect 20.48M clock 
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_0] \
				[get_bd_pins tdm_hub/clk_20_48M_int_0]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_90] \
				[get_bd_pins tdm_hub/clk_20_48M_int_90] 

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_180] \
				[get_bd_pins tdm_hub/clk_20_48M_int_180]

connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_270] \
				[get_bd_pins tdm_hub/clk_20_48M_int_270]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_ext] \
				[get_bd_pins tdm_hub/clk_20_48M_ext]
			
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
				[get_bd_pins tdm_hub/clk_100M_rst_n] \
				[get_bd_pins uart_stm/s_axi_aresetn] \
				[get_bd_pins audio/clk_100M_rst_n] \
				[get_bd_pins version_ip/S_AXI_ARESETN] \
				[get_bd_pins pll_spi/s_axi_aresetn]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M_ext] [get_bd_pins audio/clk_16_384M] 		
		
connect_bd_net 	[get_bd_ports PLL_MCLK] [get_bd_pins clock_gen/clk_16_384M]
				
connect_bd_net 	[get_bd_pins clock_gen/wclk_i2s] \
				[get_bd_pins audio/i2s_spk_lrclk] \
				[get_bd_ports I2S_0_WS]
				
connect_bd_net 	[get_bd_pins clock_gen/bclk_i2s] \
				[get_bd_pins audio/i2s_spk_bclk] \
				[get_bd_ports I2S_0_SCK]
	
#connect 20.48M reset and other signals 				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_ext_rst_n] \
				[get_bd_pins tdm_hub/clk_20_48M_ext_rst_n]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_20_48M_int_rst_n] \
				[get_bd_pins tdm_hub/clk_20_48M_int_rst_n]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M_ext_rst_n] \
				[get_bd_pins audio/clk_16_384M_rst_n]	

				
connect_bd_net 	[get_bd_pins clock_gen/wclk_bus] \
				[get_bd_pins tdm_hub/wclk_ext]


		
#connect axi
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins tdm_hub/COMM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins tdm_hub/TX_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins tdm_hub/RX_BRAM_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins uart_stm/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins version_ip/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M05_AXI] [get_bd_intf_pins pll_spi/AXI_LITE]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M06_AXI] [get_bd_intf_pins audio/AXI_GAIN_SPK]
#connect interrupt
connect_bd_net [get_bd_pins tdm_hub/INTR] [get_bd_pins intr_concat/In0]
connect_bd_net [get_bd_pins uart_stm/interrupt] [get_bd_pins intr_concat/In1]
connect_bd_net [get_bd_pins intr_concat/dout] [get_bd_pins processing_system7_0/IRQ_F2P]


connect_bd_net [get_bd_ports BUS_HUB_0_TX] [get_bd_pins tdm_hub/TX]
connect_bd_net [get_bd_ports BUS_HUB_0_RX] [get_bd_pins tdm_hub/RX]
connect_bd_net [get_bd_ports BUS_HUB_0_DIR] [get_bd_pins tdm_hub/DIR]



connect_bd_intf_net [get_bd_intf_pins uart_stm/UART] [get_bd_intf_ports UART_STM]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/UART_1] [get_bd_intf_ports UART_DBG]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/UART_0] [get_bd_intf_ports UART_CMD]


connect_bd_net [get_bd_ports GPO] [get_bd_pins processing_system7_0/GPIO_O]

connect_bd_net [get_bd_ports I2S_0_SDO] [get_bd_pins audio/i2s_spk_dout]

connect_bd_net 	[get_bd_pins audio/aes_dout] \
				[get_bd_ports AES3_2_TX] \
				[get_bd_ports AES3_1_TX]
				
connect_bd_net [get_bd_pins tdm_hub/spk_0_to_spk] [get_bd_pins audio/spk_0_to_spk]
connect_bd_net [get_bd_pins tdm_hub/spk_1_to_spk] [get_bd_pins audio/spk_1_to_spk]
connect_bd_net [get_bd_pins tdm_hub/mic_to_usb] [get_bd_pins audio/mic_to_usb]

connect_bd_net [get_bd_ports I2S_USB_SCK] [get_bd_pins audio/i2s_usb_bclk]
connect_bd_net [get_bd_ports I2S_USB_SD_IN] [get_bd_pins audio/i2s_usb_din]
connect_bd_net [get_bd_ports I2S_USB_WS] [get_bd_pins audio/i2s_usb_lrclk]
connect_bd_net [get_bd_ports I2S_USB_SD_OUT] [get_bd_pins audio/i2s_usb_dout]

connect_bd_net [get_bd_pins audio/spk_0_from_usb] [get_bd_pins tdm_hub/spk_0_from_usb]
connect_bd_net [get_bd_pins audio/spk_1_from_usb] [get_bd_pins tdm_hub/spk_1_from_usb]


connect_bd_net [get_bd_ports PLL_SPI_MOSI] [get_bd_pins pll_spi/io0_o]
connect_bd_net [get_bd_ports PLL_SPI_SCLK] [get_bd_pins pll_spi/sck_o]
connect_bd_net [get_bd_ports PLL_SPI_CS] [get_bd_pins pll_spi/ss_o]
connect_bd_net [get_bd_pins intr_concat/In2] [get_bd_pins pll_spi/ip2intc_irpt]

connect_bd_net [get_bd_ports PLL_WCLK] [get_bd_pins tdm_hub/PLL_WCLK]

connect_bd_net [get_bd_pins audio/bus_locked] [get_bd_pins tdm_hub/bus_locked]