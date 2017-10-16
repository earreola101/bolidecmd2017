
create_bd_pin -dir I $hier_name/clk_100M
create_bd_pin -dir I $hier_name/clk_100M_rst_n

create_bd_pin -dir I $hier_name/I2S_USB_SCK
create_bd_pin -dir I $hier_name/I2S_USB_WS
create_bd_pin -dir I $hier_name/I2S_USB_SD_IN
create_bd_pin -dir O $hier_name/I2S_USB_SD_OUT

create_bd_pin -dir I -from 23 -to 0 $hier_name/mic_to_usb
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_0_from_usb
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_1_from_usb

create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_receiver:1.0 $hier_name/i2s_receiver
set_property -dict [list CONFIG.NUM_BIT {16}] [get_bd_cells $hier_name/i2s_receiver]
create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_transmitter:1.0 $hier_name/i2s_transmitter

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/enable_usb
set_property -dict [list CONFIG.CONST_VAL {1}] [get_bd_cells $hier_name/enable_usb]

connect_bd_net 	[get_bd_pins $hier_name/clk_100M] \
				[get_bd_pins $hier_name/i2s_receiver/mclk] \
				[get_bd_pins $hier_name/i2s_transmitter/clk]

connect_bd_net 	[get_bd_pins $hier_name/clk_100M_rst_n] \
				[get_bd_pins $hier_name/i2s_receiver/rst_n] \
				[get_bd_pins $hier_name/i2s_transmitter/rst_n]


connect_bd_net 	[get_bd_pins $hier_name/I2S_USB_SCK] \
				[get_bd_pins $hier_name/i2s_receiver/i2s_bclk] \
				[get_bd_pins $hier_name/i2s_transmitter/i2s_bclk]

connect_bd_net 	[get_bd_pins $hier_name/I2S_USB_WS] \
				[get_bd_pins $hier_name/i2s_receiver/i2s_lrclk] \
				[get_bd_pins $hier_name/i2s_transmitter/i2s_lrclk]
				
connect_bd_net 	[get_bd_pins $hier_name/I2S_USB_SD_OUT] [get_bd_pins $hier_name/i2s_transmitter/i2s_data_out]
connect_bd_net 	[get_bd_pins $hier_name/I2S_USB_SD_IN] [get_bd_pins $hier_name/i2s_receiver/i2s_data_in]

connect_bd_net 	[get_bd_pins $hier_name/mic_to_usb] \
				[get_bd_pins $hier_name/i2s_transmitter/ch0] \
				[get_bd_pins $hier_name/i2s_transmitter/ch1]

connect_bd_net 	[get_bd_pins $hier_name/spk_0_from_usb] [get_bd_pins $hier_name/i2s_receiver/ch0]
connect_bd_net 	[get_bd_pins $hier_name/spk_1_from_usb] [get_bd_pins $hier_name/i2s_receiver/ch1]

connect_bd_net 	[get_bd_pins $hier_name/enable_usb/dout] [get_bd_pins $hier_name/i2s_receiver/enable]
connect_bd_net 	[get_bd_pins $hier_name/enable_usb/dout] [get_bd_pins $hier_name/i2s_transmitter/enable]
