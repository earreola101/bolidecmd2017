# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AUDIO_CHANNELS" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.AUDIO_CHANNELS { PARAM_VALUE.AUDIO_CHANNELS } {
	# Procedure called to update AUDIO_CHANNELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AUDIO_CHANNELS { PARAM_VALUE.AUDIO_CHANNELS } {
	# Procedure called to validate AUDIO_CHANNELS
	return true
}


proc update_MODELPARAM_VALUE.AUDIO_CHANNELS { MODELPARAM_VALUE.AUDIO_CHANNELS PARAM_VALUE.AUDIO_CHANNELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AUDIO_CHANNELS}] ${MODELPARAM_VALUE.AUDIO_CHANNELS}
}

