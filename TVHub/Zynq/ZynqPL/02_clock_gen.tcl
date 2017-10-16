
#create ports
#input
create_bd_pin -dir I clock_gen/clk_100M
create_bd_pin -dir I clock_gen/clk_16_384M
create_bd_pin -dir I clock_gen/ext_rst_n

#output
create_bd_pin -dir O clock_gen/clk_20_48M_ext

create_bd_pin -dir O clock_gen/clk_16_384M_ext
create_bd_pin -dir O clock_gen/clk_20_48M_int_0
create_bd_pin -dir O clock_gen/clk_20_48M_int_90
create_bd_pin -dir O clock_gen/clk_20_48M_int_180
create_bd_pin -dir O clock_gen/clk_20_48M_int_270


create_bd_pin -dir O clock_gen/clk_20_48M_int_rst_n
create_bd_pin -dir O clock_gen/clk_20_48M_ext_rst_n
create_bd_pin -dir O clock_gen/clk_16_384M_ext_rst_n

create_bd_pin -dir O clock_gen/clk_20_48M_int_lock
create_bd_pin -dir O clock_gen/clk_20_48M_ext_lock

create_bd_pin -dir O clock_gen/wclk_bus
create_bd_pin -dir O clock_gen/wclk_i2s
create_bd_pin -dir O clock_gen/bclk_i2s
create_bd_pin -dir O clock_gen/bclk2x_i2s


# create plls
# 100M to 20.48M
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clock_gen/clk_100M_to_20_48M
set_property -dict [list \
						CONFIG.PRIM_IN_FREQ.VALUE_SRC USER \
						CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {20.48} \
						CONFIG.USE_LOCKED {false} \
						CONFIG.USE_RESET {false} \
						CONFIG.MMCM_DIVCLK_DIVIDE {5} \
						CONFIG.MMCM_CLKFBOUT_MULT_F {48.000} \
						CONFIG.MMCM_CLKOUT0_DIVIDE_F {46.875} \
						CONFIG.CLKOUT1_JITTER {331.095} \
						CONFIG.CLKOUT1_PHASE_ERROR {301.601} \
					] [get_bd_cells clock_gen/clk_100M_to_20_48M]
					
# 4 phases of 20.48M
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clock_gen/clk_phases

set_property -dict [list \
						CONFIG.PRIMITIVE {PLL} \
						CONFIG.PRIM_SOURCE {Global_buffer} \
						CONFIG.PRIM_IN_FREQ {20.48} \
						CONFIG.CLKOUT2_USED {true} \
						CONFIG.CLKOUT3_USED {true} \
						CONFIG.CLKOUT4_USED {true} \
						CONFIG.CLKOUT1_DRIVES {BUFG} \
						CONFIG.CLKOUT2_DRIVES {BUFG} \
						CONFIG.CLKOUT3_DRIVES {BUFG} \
						CONFIG.CLKOUT4_DRIVES {BUFG} \
						CONFIG.CLKOUT5_DRIVES {BUFG} \
						CONFIG.CLKOUT6_DRIVES {BUFG} \
						CONFIG.CLKOUT7_DRIVES {BUFG} \
						CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {20.48} \
						CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {20.48} \
						CONFIG.CLKOUT2_REQUESTED_PHASE {90} \
						CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {20.48} \
						CONFIG.CLKOUT3_REQUESTED_PHASE {180} \
						CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {20.48} \
						CONFIG.CLKOUT4_REQUESTED_PHASE {270} \
						CONFIG.USE_RESET {false} \
						CONFIG.CLKIN1_JITTER_PS {488.28000000000003} \
						CONFIG.MMCM_DIVCLK_DIVIDE {1} \
						CONFIG.MMCM_CLKFBOUT_MULT_F {40} \
						CONFIG.MMCM_COMPENSATION {ZHOLD} \
						CONFIG.MMCM_CLKIN1_PERIOD {48.828} \
						CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
						CONFIG.MMCM_CLKOUT0_DIVIDE_F {40} \
						CONFIG.MMCM_CLKOUT1_DIVIDE {40} \
						CONFIG.MMCM_CLKOUT1_PHASE {90.000} \
						CONFIG.MMCM_CLKOUT2_DIVIDE {40} \
						CONFIG.MMCM_CLKOUT2_PHASE {180.000} \
						CONFIG.MMCM_CLKOUT3_DIVIDE {40} \
						CONFIG.MMCM_CLKOUT3_PHASE {270.000} \
						CONFIG.NUM_OUT_CLKS {4} \
						CONFIG.CLKOUT1_JITTER {481.859} \
						CONFIG.CLKOUT1_PHASE_ERROR {305.806} \
						CONFIG.CLKOUT2_JITTER {481.859} \
						CONFIG.CLKOUT2_PHASE_ERROR {305.806} \
						CONFIG.CLKOUT3_JITTER {481.859} \
						CONFIG.CLKOUT3_PHASE_ERROR {305.806} \
						CONFIG.CLKOUT4_JITTER {481.859} \
						CONFIG.CLKOUT4_PHASE_ERROR {305.806} \
					] [get_bd_cells clock_gen/clk_phases]

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clock_gen/clk_16_384M_to_20_48M		
set_property -dict [list \
						CONFIG.PRIM_IN_FREQ {16.384} \
						CONFIG.CLKOUT2_USED {true} \
						CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {16.384} \
						CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {20.480} \
						CONFIG.USE_RESET {false} \
						CONFIG.CLKIN1_JITTER_PS {610.3499999999999} \
						CONFIG.MMCM_DIVCLK_DIVIDE {1} \
						CONFIG.MMCM_CLKFBOUT_MULT_F {61.250} \
						CONFIG.MMCM_CLKIN1_PERIOD {61.035} \
						CONFIG.MMCM_CLKOUT0_DIVIDE_F {61.250} \
						CONFIG.MMCM_CLKOUT1_DIVIDE {49} \
						CONFIG.NUM_OUT_CLKS {2} \
						CONFIG.CLKOUT1_JITTER {385.776} \
						CONFIG.CLKOUT1_PHASE_ERROR {418.030} \
						CONFIG.CLKOUT2_JITTER {362.055} \
						CONFIG.CLKOUT2_PHASE_ERROR {418.030} \
					] [get_bd_cells clock_gen/clk_16_384M_to_20_48M]
			
#reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 clock_gen/proc_sys_reset_int
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 clock_gen/proc_sys_reset_ext
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 clock_gen/proc_sys_reset_aud_ext

#i2s signals
create_bd_cell -type ip -vlnv bdsound.com:user:audio_clock_gen:1.0 clock_gen/audio_clock_i2s
set_property -dict [list CONFIG.SHIFT_DIV {1}] [get_bd_cells clock_gen/audio_clock_i2s]
create_bd_cell -type ip -vlnv bdsound.com:user:audio_clock_gen:1.0 clock_gen/audio_clock_bus




#connect signals
connect_bd_net [get_bd_pins clock_gen/clk_100M] [get_bd_pins clock_gen/clk_100M_to_20_48M/clk_in1]
connect_bd_net [get_bd_pins clock_gen/clk_100M_to_20_48M/clk_out1] [get_bd_pins clock_gen/clk_phases/clk_in1]
connect_bd_net [get_bd_pins clock_gen/clk_phases/clk_out1] [get_bd_pins clock_gen/clk_20_48M_int_0] 
connect_bd_net [get_bd_pins clock_gen/clk_phases/clk_out2] [get_bd_pins clock_gen/clk_20_48M_int_90] 
connect_bd_net [get_bd_pins clock_gen/clk_phases/clk_out3] [get_bd_pins clock_gen/clk_20_48M_int_180] 
connect_bd_net [get_bd_pins clock_gen/clk_phases/clk_out4] [get_bd_pins clock_gen/clk_20_48M_int_270]

connect_bd_net 	[get_bd_pins clock_gen/clk_phases/locked] \
				[get_bd_pins clock_gen/clk_20_48M_int_lock] \
				[get_bd_pins clock_gen/proc_sys_reset_int/dcm_locked]
				
connect_bd_net [get_bd_pins clock_gen/clk_phases/clk_out1] [get_bd_pins clock_gen/proc_sys_reset_int/slowest_sync_clk]
connect_bd_net [get_bd_pins clock_gen/ext_rst_n] [get_bd_pins clock_gen/proc_sys_reset_int/ext_reset_in]
connect_bd_net [get_bd_pins clock_gen/clk_20_48M_int_rst_n] [get_bd_pins clock_gen/proc_sys_reset_int/peripheral_aresetn]


connect_bd_net [get_bd_pins clock_gen/clk_16_384M] [get_bd_pins clock_gen/clk_16_384M_to_20_48M/clk_in1]

connect_bd_net [get_bd_pins clock_gen/clk_16_384M_to_20_48M/clk_out2] [get_bd_pins clock_gen/proc_sys_reset_ext/slowest_sync_clk]
connect_bd_net [get_bd_pins clock_gen/clk_16_384M_to_20_48M/clk_out1] [get_bd_pins clock_gen/proc_sys_reset_aud_ext/slowest_sync_clk]

connect_bd_net [get_bd_pins clock_gen/ext_rst_n] [get_bd_pins clock_gen/proc_sys_reset_ext/ext_reset_in]
connect_bd_net [get_bd_pins clock_gen/ext_rst_n] [get_bd_pins clock_gen/proc_sys_reset_aud_ext/ext_reset_in]
connect_bd_net [get_bd_pins clock_gen/clk_20_48M_ext_rst_n] [get_bd_pins clock_gen/proc_sys_reset_ext/peripheral_aresetn]
connect_bd_net [get_bd_pins clock_gen/clk_16_384M_ext_rst_n] [get_bd_pins clock_gen/proc_sys_reset_aud_ext/peripheral_aresetn]



connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M_to_20_48M/clk_out1] \
				[get_bd_pins clock_gen/audio_clock_i2s/clk] \
				[get_bd_pins clock_gen/clk_16_384M_ext]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M_to_20_48M/clk_out2] \
				[get_bd_pins clock_gen/clk_20_48M_ext] \
				[get_bd_pins clock_gen/audio_clock_bus/clk]
				
connect_bd_net 	[get_bd_pins clock_gen/clk_16_384M_to_20_48M/locked] \
				[get_bd_pins clock_gen/audio_clock_i2s/lock] \
				[get_bd_pins clock_gen/audio_clock_bus/lock] \
				[get_bd_pins clock_gen/clk_20_48M_ext_lock] \
				[get_bd_pins clock_gen/proc_sys_reset_ext/dcm_locked] \
				[get_bd_pins clock_gen/proc_sys_reset_aud_ext/dcm_locked]
				
connect_bd_net [get_bd_pins clock_gen/wclk_bus] [get_bd_pins clock_gen/audio_clock_bus/wclk32]
connect_bd_net [get_bd_pins clock_gen/wclk_i2s] [get_bd_pins clock_gen/audio_clock_i2s/wclk]
connect_bd_net [get_bd_pins clock_gen/bclk_i2s] [get_bd_pins clock_gen/audio_clock_i2s/bclk]
connect_bd_net [get_bd_pins clock_gen/bclk2x_i2s] [get_bd_pins clock_gen/audio_clock_i2s/bclk2x]




