# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set BUF_IN [ipgui::add_param $IPINST -name "BUF_IN" -parent ${Page_0}]
  set_property tooltip {Enable this if really having trouble meeting timing} ${BUF_IN}
  set BUF_OUT [ipgui::add_param $IPINST -name "BUF_OUT" -parent ${Page_0}]
  set_property tooltip {Only disable this if you think you can get away with it} ${BUF_OUT}
  set ENABLE_BACKPRESSURE [ipgui::add_param $IPINST -name "ENABLE_BACKPRESSURE" -parent ${Page_0}]
  set_property tooltip {The snoop interface will assert backpressure instead of dropping packets} ${ENABLE_BACKPRESSURE}
  set INST_MEM_DEPTH [ipgui::add_param $IPINST -name "INST_MEM_DEPTH" -parent ${Page_0}]
  set_property tooltip {This will be rounded up internally to a power of 2. Sets the size of the instruction memory} ${INST_MEM_DEPTH}
  set N [ipgui::add_param $IPINST -name "N" -parent ${Page_0}]
  set_property tooltip {Number of parallel packetfilter cores} ${N}
  set PACKET_MEM_BYTES [ipgui::add_param $IPINST -name "PACKET_MEM_BYTES" -parent ${Page_0}]
  set_property tooltip {Will be used to generate internal buffers. Will be internally rounded up to a power of 2, but soon this will be fixed} ${PACKET_MEM_BYTES}
  set PESS [ipgui::add_param $IPINST -name "PESS" -parent ${Page_0}]
  set_property tooltip {If you are really desperate, this option enables several extra registers to help ease timing} ${PESS}
  ipgui::add_param $IPINST -name "SN_FWD_DATA_WIDTH" -parent ${Page_0}

  set SHOW_DBG_PORTS [ipgui::add_param $IPINST -name "SHOW_DBG_PORTS"]
  set_property tooltip {Exports some information from CPU0 for looking at in an ILA} ${SHOW_DBG_PORTS}

}

proc update_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to update AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to validate AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.BUF_IN { PARAM_VALUE.BUF_IN } {
	# Procedure called to update BUF_IN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUF_IN { PARAM_VALUE.BUF_IN } {
	# Procedure called to validate BUF_IN
	return true
}

proc update_PARAM_VALUE.BUF_OUT { PARAM_VALUE.BUF_OUT } {
	# Procedure called to update BUF_OUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUF_OUT { PARAM_VALUE.BUF_OUT } {
	# Procedure called to validate BUF_OUT
	return true
}

proc update_PARAM_VALUE.BYTE_ADDR_WIDTH { PARAM_VALUE.BYTE_ADDR_WIDTH } {
	# Procedure called to update BYTE_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYTE_ADDR_WIDTH { PARAM_VALUE.BYTE_ADDR_WIDTH } {
	# Procedure called to validate BYTE_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.CODE_ADDR_WIDTH { PARAM_VALUE.CODE_ADDR_WIDTH } {
	# Procedure called to update CODE_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CODE_ADDR_WIDTH { PARAM_VALUE.CODE_ADDR_WIDTH } {
	# Procedure called to validate CODE_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.CODE_DATA_WIDTH { PARAM_VALUE.CODE_DATA_WIDTH } {
	# Procedure called to update CODE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CODE_DATA_WIDTH { PARAM_VALUE.CODE_DATA_WIDTH } {
	# Procedure called to validate CODE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.ENABLE_BACKPRESSURE { PARAM_VALUE.ENABLE_BACKPRESSURE } {
	# Procedure called to update ENABLE_BACKPRESSURE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_BACKPRESSURE { PARAM_VALUE.ENABLE_BACKPRESSURE } {
	# Procedure called to validate ENABLE_BACKPRESSURE
	return true
}

proc update_PARAM_VALUE.INST_MEM_DEPTH { PARAM_VALUE.INST_MEM_DEPTH } {
	# Procedure called to update INST_MEM_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_MEM_DEPTH { PARAM_VALUE.INST_MEM_DEPTH } {
	# Procedure called to validate INST_MEM_DEPTH
	return true
}

proc update_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to update N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to validate N
	return true
}

proc update_PARAM_VALUE.PACKET_MEM_BYTES { PARAM_VALUE.PACKET_MEM_BYTES } {
	# Procedure called to update PACKET_MEM_BYTES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PACKET_MEM_BYTES { PARAM_VALUE.PACKET_MEM_BYTES } {
	# Procedure called to validate PACKET_MEM_BYTES
	return true
}

proc update_PARAM_VALUE.PESS { PARAM_VALUE.PESS } {
	# Procedure called to update PESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PESS { PARAM_VALUE.PESS } {
	# Procedure called to validate PESS
	return true
}

proc update_PARAM_VALUE.SHOW_DBG_PORTS { PARAM_VALUE.SHOW_DBG_PORTS } {
	# Procedure called to update SHOW_DBG_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHOW_DBG_PORTS { PARAM_VALUE.SHOW_DBG_PORTS } {
	# Procedure called to validate SHOW_DBG_PORTS
	return true
}

proc update_PARAM_VALUE.SN_FWD_DATA_WIDTH { PARAM_VALUE.SN_FWD_DATA_WIDTH } {
	# Procedure called to update SN_FWD_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SN_FWD_DATA_WIDTH { PARAM_VALUE.SN_FWD_DATA_WIDTH } {
	# Procedure called to validate SN_FWD_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.N { MODELPARAM_VALUE.N PARAM_VALUE.N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N}] ${MODELPARAM_VALUE.N}
}

proc update_MODELPARAM_VALUE.PACKET_MEM_BYTES { MODELPARAM_VALUE.PACKET_MEM_BYTES PARAM_VALUE.PACKET_MEM_BYTES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PACKET_MEM_BYTES}] ${MODELPARAM_VALUE.PACKET_MEM_BYTES}
}

proc update_MODELPARAM_VALUE.INST_MEM_DEPTH { MODELPARAM_VALUE.INST_MEM_DEPTH PARAM_VALUE.INST_MEM_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_MEM_DEPTH}] ${MODELPARAM_VALUE.INST_MEM_DEPTH}
}

proc update_MODELPARAM_VALUE.SN_FWD_DATA_WIDTH { MODELPARAM_VALUE.SN_FWD_DATA_WIDTH PARAM_VALUE.SN_FWD_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SN_FWD_DATA_WIDTH}] ${MODELPARAM_VALUE.SN_FWD_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BUF_IN { MODELPARAM_VALUE.BUF_IN PARAM_VALUE.BUF_IN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUF_IN}] ${MODELPARAM_VALUE.BUF_IN}
}

proc update_MODELPARAM_VALUE.BUF_OUT { MODELPARAM_VALUE.BUF_OUT PARAM_VALUE.BUF_OUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUF_OUT}] ${MODELPARAM_VALUE.BUF_OUT}
}

proc update_MODELPARAM_VALUE.PESS { MODELPARAM_VALUE.PESS PARAM_VALUE.PESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PESS}] ${MODELPARAM_VALUE.PESS}
}

proc update_MODELPARAM_VALUE.ENABLE_BACKPRESSURE { MODELPARAM_VALUE.ENABLE_BACKPRESSURE PARAM_VALUE.ENABLE_BACKPRESSURE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_BACKPRESSURE}] ${MODELPARAM_VALUE.ENABLE_BACKPRESSURE}
}

proc update_MODELPARAM_VALUE.CODE_ADDR_WIDTH { MODELPARAM_VALUE.CODE_ADDR_WIDTH PARAM_VALUE.CODE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CODE_ADDR_WIDTH}] ${MODELPARAM_VALUE.CODE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.CODE_DATA_WIDTH { MODELPARAM_VALUE.CODE_DATA_WIDTH PARAM_VALUE.CODE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CODE_DATA_WIDTH}] ${MODELPARAM_VALUE.CODE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BYTE_ADDR_WIDTH { MODELPARAM_VALUE.BYTE_ADDR_WIDTH PARAM_VALUE.BYTE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYTE_ADDR_WIDTH}] ${MODELPARAM_VALUE.BYTE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_ADDR_WIDTH { MODELPARAM_VALUE.AXI_ADDR_WIDTH PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.AXI_ADDR_WIDTH}
}

