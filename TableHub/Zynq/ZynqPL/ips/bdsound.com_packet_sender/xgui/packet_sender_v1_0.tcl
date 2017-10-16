
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/packet_sender_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "MAX_PACKET_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PACKET_MEMORY_BIT_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PORT_NUMBER" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "PORT_1_TRUE_BRAM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PORT_2_TRUE_BRAM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PORT_3_TRUE_BRAM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PORT_4_TRUE_BRAM" -parent ${Page_0}


}

proc update_PARAM_VALUE.PORT_2_TRUE_BRAM { PARAM_VALUE.PORT_2_TRUE_BRAM PARAM_VALUE.PORT_NUMBER } {
	# Procedure called to update PORT_2_TRUE_BRAM when any of the dependent parameters in the arguments change
	
	set PORT_2_TRUE_BRAM ${PARAM_VALUE.PORT_2_TRUE_BRAM}
	set PORT_NUMBER ${PARAM_VALUE.PORT_NUMBER}
	set values(PORT_NUMBER) [get_property value $PORT_NUMBER]
	if { [gen_USERPARAMETER_PORT_2_TRUE_BRAM_ENABLEMENT $values(PORT_NUMBER)] } {
		set_property enabled true $PORT_2_TRUE_BRAM
	} else {
		set_property enabled false $PORT_2_TRUE_BRAM
	}
}

proc validate_PARAM_VALUE.PORT_2_TRUE_BRAM { PARAM_VALUE.PORT_2_TRUE_BRAM } {
	# Procedure called to validate PORT_2_TRUE_BRAM
	return true
}

proc update_PARAM_VALUE.PORT_3_TRUE_BRAM { PARAM_VALUE.PORT_3_TRUE_BRAM PARAM_VALUE.PORT_NUMBER } {
	# Procedure called to update PORT_3_TRUE_BRAM when any of the dependent parameters in the arguments change
	
	set PORT_3_TRUE_BRAM ${PARAM_VALUE.PORT_3_TRUE_BRAM}
	set PORT_NUMBER ${PARAM_VALUE.PORT_NUMBER}
	set values(PORT_NUMBER) [get_property value $PORT_NUMBER]
	if { [gen_USERPARAMETER_PORT_3_TRUE_BRAM_ENABLEMENT $values(PORT_NUMBER)] } {
		set_property enabled true $PORT_3_TRUE_BRAM
	} else {
		set_property enabled false $PORT_3_TRUE_BRAM
	}
}

proc validate_PARAM_VALUE.PORT_3_TRUE_BRAM { PARAM_VALUE.PORT_3_TRUE_BRAM } {
	# Procedure called to validate PORT_3_TRUE_BRAM
	return true
}

proc update_PARAM_VALUE.PORT_4_TRUE_BRAM { PARAM_VALUE.PORT_4_TRUE_BRAM PARAM_VALUE.PORT_NUMBER } {
	# Procedure called to update PORT_4_TRUE_BRAM when any of the dependent parameters in the arguments change
	
	set PORT_4_TRUE_BRAM ${PARAM_VALUE.PORT_4_TRUE_BRAM}
	set PORT_NUMBER ${PARAM_VALUE.PORT_NUMBER}
	set values(PORT_NUMBER) [get_property value $PORT_NUMBER]
	if { [gen_USERPARAMETER_PORT_4_TRUE_BRAM_ENABLEMENT $values(PORT_NUMBER)] } {
		set_property enabled true $PORT_4_TRUE_BRAM
	} else {
		set_property enabled false $PORT_4_TRUE_BRAM
	}
}

proc validate_PARAM_VALUE.PORT_4_TRUE_BRAM { PARAM_VALUE.PORT_4_TRUE_BRAM } {
	# Procedure called to validate PORT_4_TRUE_BRAM
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

proc update_PARAM_VALUE.PORT_1_TRUE_BRAM { PARAM_VALUE.PORT_1_TRUE_BRAM } {
	# Procedure called to update PORT_1_TRUE_BRAM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PORT_1_TRUE_BRAM { PARAM_VALUE.PORT_1_TRUE_BRAM } {
	# Procedure called to validate PORT_1_TRUE_BRAM
	return true
}

proc update_PARAM_VALUE.PORT_NUMBER { PARAM_VALUE.PORT_NUMBER } {
	# Procedure called to update PORT_NUMBER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PORT_NUMBER { PARAM_VALUE.PORT_NUMBER } {
	# Procedure called to validate PORT_NUMBER
	return true
}


proc update_MODELPARAM_VALUE.MAX_PACKET_SIZE { MODELPARAM_VALUE.MAX_PACKET_SIZE PARAM_VALUE.MAX_PACKET_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_PACKET_SIZE}] ${MODELPARAM_VALUE.MAX_PACKET_SIZE}
}

proc update_MODELPARAM_VALUE.PACKET_MEMORY_BIT_ADDR { MODELPARAM_VALUE.PACKET_MEMORY_BIT_ADDR PARAM_VALUE.PACKET_MEMORY_BIT_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PACKET_MEMORY_BIT_ADDR}] ${MODELPARAM_VALUE.PACKET_MEMORY_BIT_ADDR}
}

proc update_MODELPARAM_VALUE.PORT_1_TRUE_BRAM { MODELPARAM_VALUE.PORT_1_TRUE_BRAM PARAM_VALUE.PORT_1_TRUE_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_1_TRUE_BRAM}] ${MODELPARAM_VALUE.PORT_1_TRUE_BRAM}
}

proc update_MODELPARAM_VALUE.PORT_2_TRUE_BRAM { MODELPARAM_VALUE.PORT_2_TRUE_BRAM PARAM_VALUE.PORT_2_TRUE_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_2_TRUE_BRAM}] ${MODELPARAM_VALUE.PORT_2_TRUE_BRAM}
}

proc update_MODELPARAM_VALUE.PORT_3_TRUE_BRAM { MODELPARAM_VALUE.PORT_3_TRUE_BRAM PARAM_VALUE.PORT_3_TRUE_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_3_TRUE_BRAM}] ${MODELPARAM_VALUE.PORT_3_TRUE_BRAM}
}

proc update_MODELPARAM_VALUE.PORT_4_TRUE_BRAM { MODELPARAM_VALUE.PORT_4_TRUE_BRAM PARAM_VALUE.PORT_4_TRUE_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_4_TRUE_BRAM}] ${MODELPARAM_VALUE.PORT_4_TRUE_BRAM}
}

proc update_MODELPARAM_VALUE.PORT_NUMBER { MODELPARAM_VALUE.PORT_NUMBER PARAM_VALUE.PORT_NUMBER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_NUMBER}] ${MODELPARAM_VALUE.PORT_NUMBER}
}

