create_bd_pin -dir I $hier_name/clk_100M
create_bd_pin -dir I $hier_name/clk_100M_rst_n

create_bd_pin -dir I $hier_name/clk_16_384M
create_bd_pin -dir I $hier_name/clk_16_384M_rst_n

create_bd_pin -dir I $hier_name/i2s_spk_lrclk
create_bd_pin -dir I $hier_name/i2s_spk_bclk
create_bd_pin -dir O $hier_name/i2s_spk_dout

create_bd_pin -dir I $hier_name/i2s_usb_lrclk
create_bd_pin -dir I $hier_name/i2s_usb_bclk
create_bd_pin -dir O $hier_name/i2s_usb_dout
create_bd_pin -dir I $hier_name/i2s_usb_din

create_bd_pin -dir O $hier_name/aes_dout
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_0_to_spk
create_bd_pin -dir I -from 23 -to 0 $hier_name/spk_1_to_spk

create_bd_pin -dir I -from 23 -to 0 $hier_name/mic_to_usb
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_0_from_usb
create_bd_pin -dir O -from 23 -to 0 $hier_name/spk_1_from_usb
create_bd_pin -dir I $hier_name/bus_locked

create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 $hier_name/AXI_GAIN_SPK

create_bd_cell -type ip -vlnv bdsound.com:user:gain_block:1.0 $hier_name/gain_block
create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_transmitter:1.0 $hier_name/i2s_tx_spk
create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_transmitter:1.0 $hier_name/i2s_tx_usb
create_bd_cell -type ip -vlnv bdsound.com:audio:i2s_receiver:1.0 $hier_name/i2s_rx_usb

create_bd_cell -type ip -vlnv bdsound.com:user:bdAES3tx_simple:1.0 $hier_name/aes_tx_spk
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 $hier_name/reset_not
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells $hier_name/reset_not]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/aes_freq_const
set_property -dict [list CONFIG.CONST_WIDTH {2} CONFIG.CONST_VAL {2}] [get_bd_cells $hier_name/aes_freq_const]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $hier_name/en_const
set_property -dict [list CONFIG.CONST_VAL {1}] [get_bd_cells $hier_name/en_const]



connect_bd_net 	[get_bd_pins $hier_name/clk_100M] \
				[get_bd_pins $hier_name/i2s_tx_spk/clk] \
				[get_bd_pins $hier_name/i2s_tx_usb/clk] \
				[get_bd_pins $hier_name/i2s_rx_usb/mclk] \
				[get_bd_pins $hier_name/gain_block/clk]
				
connect_bd_net 	[get_bd_pins $hier_name/clk_16_384M] [get_bd_pins $hier_name/aes_tx_spk/audio_clk]				

connect_bd_net 	[get_bd_pins $hier_name/clk_100M_rst_n] \
				[get_bd_pins $hier_name/i2s_tx_spk/rst_n] \
				[get_bd_pins $hier_name/i2s_tx_usb/rst_n] \
				[get_bd_pins $hier_name/i2s_rx_usb/rst_n] \
				[get_bd_pins $hier_name/gain_block/rst_n]
				
connect_bd_net 	[get_bd_pins $hier_name/bus_locked] [get_bd_pins $hier_name/reset_not/Op1]
#connect_bd_net 	[get_bd_pins $hier_name/clk_16_384M_rst_n] [get_bd_pins $hier_name/reset_not/Op1]

connect_bd_net 	[get_bd_pins $hier_name/reset_not/Res] [get_bd_pins $hier_name/aes_tx_spk/rst]

# connect_bd_net 	[get_bd_pins $hier_name/spk_0_to_spk] \
				# [get_bd_pins $hier_name/i2s_tx_spk/ch0] \
				# [get_bd_pins $hier_name/aes_tx_spk/ch0_in]
				
# connect_bd_net 	[get_bd_pins $hier_name/spk_1_to_spk] \
				# [get_bd_pins $hier_name/i2s_tx_spk/ch1] \
				# [get_bd_pins $hier_name/aes_tx_spk/ch1_in]
				
connect_bd_intf_net [get_bd_intf_pins $hier_name/AXI_GAIN_SPK] [get_bd_intf_pins $hier_name/gain_block/S_AXI]	
connect_bd_net [get_bd_pins $hier_name/spk_0_to_spk] [get_bd_pins $hier_name/gain_block/in0]
connect_bd_net [get_bd_pins $hier_name/spk_1_to_spk] [get_bd_pins $hier_name/gain_block/in1]

connect_bd_net 	[get_bd_pins $hier_name/gain_block/out0] \
				[get_bd_pins $hier_name/i2s_tx_spk/ch0] \
				[get_bd_pins $hier_name/aes_tx_spk/ch0_in]
				
connect_bd_net 	[get_bd_pins $hier_name/gain_block/out1] \
				[get_bd_pins $hier_name/i2s_tx_spk/ch1] \
				[get_bd_pins $hier_name/aes_tx_spk/ch1_in]
				
				
connect_bd_net 	[get_bd_pins $hier_name/aes_freq_const/dout] [get_bd_pins $hier_name/aes_tx_spk/out_freq]	
			
connect_bd_net 	[get_bd_pins $hier_name/en_const/dout] \
				[get_bd_pins $hier_name/i2s_tx_spk/enable] \
				[get_bd_pins $hier_name/i2s_tx_usb/enable] \
				[get_bd_pins $hier_name/i2s_rx_usb/enable]

connect_bd_net [get_bd_pins $hier_name/i2s_spk_bclk] [get_bd_pins $hier_name/i2s_tx_spk/i2s_bclk]

connect_bd_net 	[get_bd_pins $hier_name/i2s_spk_lrclk] \
				[get_bd_pins $hier_name/i2s_tx_spk/i2s_lrclk] \
				[get_bd_pins $hier_name/gain_block/lrclk]
				
connect_bd_net [get_bd_pins $hier_name/i2s_spk_dout] [get_bd_pins $hier_name/i2s_tx_spk/i2s_data_out]

connect_bd_net 	[get_bd_pins $hier_name/i2s_usb_bclk] \
				[get_bd_pins $hier_name/i2s_tx_usb/i2s_bclk] \
				[get_bd_pins $hier_name/i2s_rx_usb/i2s_bclk]
				
connect_bd_net 	[get_bd_pins $hier_name/i2s_usb_lrclk] \
				[get_bd_pins $hier_name/i2s_tx_usb/i2s_lrclk] \
				[get_bd_pins  $hier_name/i2s_rx_usb/i2s_lrclk]
				
connect_bd_net 	[get_bd_pins $hier_name/i2s_usb_dout] [get_bd_pins $hier_name/i2s_tx_usb/i2s_data_out]
connect_bd_net 	[get_bd_pins  $hier_name/i2s_usb_din] [get_bd_pins $hier_name/i2s_rx_usb/i2s_data_in]

connect_bd_net 	[get_bd_pins $hier_name/aes_dout] [get_bd_pins $hier_name/aes_tx_spk/dout]

connect_bd_net 	[get_bd_pins $hier_name/mic_to_usb] \
				[get_bd_pins $hier_name/i2s_tx_usb/ch0] \
				[get_bd_pins $hier_name/i2s_tx_usb/ch1]

				
				
				
connect_bd_net 	[get_bd_pins $hier_name/spk_0_from_usb] [get_bd_pins $hier_name/i2s_rx_usb/ch0]
connect_bd_net 	[get_bd_pins $hier_name/spk_1_from_usb] [get_bd_pins $hier_name/i2s_rx_usb/ch1]




