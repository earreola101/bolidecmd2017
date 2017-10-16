# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set CHOOSE_SINE [ipgui::add_param $IPINST -parent $Page0 -name CHOOSE_SINE]
	set SHIFT_DIVISOR [ipgui::add_param $IPINST -parent $Page0 -name SHIFT_DIVISOR]
}

proc update_PARAM_VALUE.CHOOSE_SINE { PARAM_VALUE.CHOOSE_SINE } {
	# Procedure called to update CHOOSE_SINE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CHOOSE_SINE { PARAM_VALUE.CHOOSE_SINE } {
	# Procedure called to validate CHOOSE_SINE
	return true
}

proc update_PARAM_VALUE.SHIFT_DIVISOR { PARAM_VALUE.SHIFT_DIVISOR } {
	# Procedure called to update SHIFT_DIVISOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_DIVISOR { PARAM_VALUE.SHIFT_DIVISOR } {
	# Procedure called to validate SHIFT_DIVISOR
	return true
}


proc update_MODELPARAM_VALUE.SHIFT_DIVISOR { MODELPARAM_VALUE.SHIFT_DIVISOR PARAM_VALUE.SHIFT_DIVISOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_DIVISOR}] ${MODELPARAM_VALUE.SHIFT_DIVISOR}
}

proc update_MODELPARAM_VALUE.CHOOSE_SINE { MODELPARAM_VALUE.CHOOSE_SINE PARAM_VALUE.CHOOSE_SINE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CHOOSE_SINE}] ${MODELPARAM_VALUE.CHOOSE_SINE}
}

