# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CIRCULAR_MEMORY_BIT_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CIRCULAR_MEMORY_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_PACKET_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PACKET_MEMORY_BIT_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TRUE_BRAM" -parent ${Page_0}


}

proc update_PARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR { PARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR } {
	# Procedure called to update CIRCULAR_MEMORY_BIT_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR { PARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR } {
	# Procedure called to validate CIRCULAR_MEMORY_BIT_ADDR
	return true
}

proc update_PARAM_VALUE.CIRCULAR_MEMORY_SIZE { PARAM_VALUE.CIRCULAR_MEMORY_SIZE } {
	# Procedure called to update CIRCULAR_MEMORY_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CIRCULAR_MEMORY_SIZE { PARAM_VALUE.CIRCULAR_MEMORY_SIZE } {
	# Procedure called to validate CIRCULAR_MEMORY_SIZE
	return true
}

proc update_PARAM_VALUE.MAX_PACKET_SIZE { PARAM_VALUE.MAX_PACKET_SIZE } {
	# Procedure called to update MAX_PACKET_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_PACKET_SIZE { PARAM_VALUE.MAX_PACKET_SIZE } {
	# Procedure called to validate MAX_PACKET_SIZE
	return true
}

proc update_PARAM_VALUE.PACKET_MEMORY_BIT_ADDR { PARAM_VALUE.PACKET_MEMORY_BIT_ADDR } {
	# Procedure called to update PACKET_MEMORY_BIT_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PACKET_MEMORY_BIT_ADDR { PARAM_VALUE.PACKET_MEMORY_BIT_ADDR } {
	# Procedure called to validate PACKET_MEMORY_BIT_ADDR
	return true
}

proc update_PARAM_VALUE.TRUE_BRAM { PARAM_VALUE.TRUE_BRAM } {
	# Procedure called to update TRUE_BRAM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRUE_BRAM { PARAM_VALUE.TRUE_BRAM } {
	# Procedure called to validate TRUE_BRAM
	return true
}


proc update_MODELPARAM_VALUE.MAX_PACKET_SIZE { MODELPARAM_VALUE.MAX_PACKET_SIZE PARAM_VALUE.MAX_PACKET_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_PACKET_SIZE}] ${MODELPARAM_VALUE.MAX_PACKET_SIZE}
}

proc update_MODELPARAM_VALUE.CIRCULAR_MEMORY_SIZE { MODELPARAM_VALUE.CIRCULAR_MEMORY_SIZE PARAM_VALUE.CIRCULAR_MEMORY_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CIRCULAR_MEMORY_SIZE}] ${MODELPARAM_VALUE.CIRCULAR_MEMORY_SIZE}
}

proc update_MODELPARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR { MODELPARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR PARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR}] ${MODELPARAM_VALUE.CIRCULAR_MEMORY_BIT_ADDR}
}

proc update_MODELPARAM_VALUE.PACKET_MEMORY_BIT_ADDR { MODELPARAM_VALUE.PACKET_MEMORY_BIT_ADDR PARAM_VALUE.PACKET_MEMORY_BIT_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PACKET_MEMORY_BIT_ADDR}] ${MODELPARAM_VALUE.PACKET_MEMORY_BIT_ADDR}
}

proc update_MODELPARAM_VALUE.TRUE_BRAM { MODELPARAM_VALUE.TRUE_BRAM PARAM_VALUE.TRUE_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRUE_BRAM}] ${MODELPARAM_VALUE.TRUE_BRAM}
}

