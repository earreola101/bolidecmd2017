# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "MCLK_FREQUENCY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WCLK_FREQUENCY" -parent ${Page_0}


}

proc update_PARAM_VALUE.MCLK_FREQUENCY { PARAM_VALUE.MCLK_FREQUENCY } {
	# Procedure called to update MCLK_FREQUENCY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MCLK_FREQUENCY { PARAM_VALUE.MCLK_FREQUENCY } {
	# Procedure called to validate MCLK_FREQUENCY
	return true
}

proc update_PARAM_VALUE.WCLK_FREQUENCY { PARAM_VALUE.WCLK_FREQUENCY } {
	# Procedure called to update WCLK_FREQUENCY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WCLK_FREQUENCY { PARAM_VALUE.WCLK_FREQUENCY } {
	# Procedure called to validate WCLK_FREQUENCY
	return true
}


proc update_MODELPARAM_VALUE.MCLK_FREQUENCY { MODELPARAM_VALUE.MCLK_FREQUENCY PARAM_VALUE.MCLK_FREQUENCY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MCLK_FREQUENCY}] ${MODELPARAM_VALUE.MCLK_FREQUENCY}
}

proc update_MODELPARAM_VALUE.WCLK_FREQUENCY { MODELPARAM_VALUE.WCLK_FREQUENCY PARAM_VALUE.WCLK_FREQUENCY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WCLK_FREQUENCY}] ${MODELPARAM_VALUE.WCLK_FREQUENCY}
}

