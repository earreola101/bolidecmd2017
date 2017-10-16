# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DELAY_COUNTER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RST_VAL" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.DELAY_COUNTER { PARAM_VALUE.DELAY_COUNTER } {
	# Procedure called to update DELAY_COUNTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY_COUNTER { PARAM_VALUE.DELAY_COUNTER } {
	# Procedure called to validate DELAY_COUNTER
	return true
}

proc update_PARAM_VALUE.RST_VAL { PARAM_VALUE.RST_VAL } {
	# Procedure called to update RST_VAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RST_VAL { PARAM_VALUE.RST_VAL } {
	# Procedure called to validate RST_VAL
	return true
}


proc update_MODELPARAM_VALUE.DELAY_COUNTER { MODELPARAM_VALUE.DELAY_COUNTER PARAM_VALUE.DELAY_COUNTER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY_COUNTER}] ${MODELPARAM_VALUE.DELAY_COUNTER}
}

proc update_MODELPARAM_VALUE.RST_VAL { MODELPARAM_VALUE.RST_VAL PARAM_VALUE.RST_VAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RST_VAL}] ${MODELPARAM_VALUE.RST_VAL}
}

