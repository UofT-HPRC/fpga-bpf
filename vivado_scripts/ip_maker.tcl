# Copied from Clark's traffic generator project
# Modified to match the particular project

# Call as:
# vivado -mode tcl -nolog -nojournal -source scripts/ip_package.tcl -tclargs $ip_name $part_name

# start_gui

set ip_name [lindex $argv 0]
set part_name [lindex $argv 1]
set project_name ${ip_name}_ip
create_project ${project_name} ${project_name} -part ${part_name}
add_files ${ip_name}/src
ipx::package_project -root_dir ${ip_name} -vendor Marco_Merlini -library fpga_bpf -taxonomy /UserIP

# Fix monitor interface for snooper
ipx::remove_port_map TREADY [ipx::get_bus_interfaces sn -of_objects [ipx::current_core]]
set_property interface_mode monitor [ipx::get_bus_interfaces sn -of_objects [ipx::current_core]]
ipx::add_port_map TREADY [ipx::get_bus_interfaces sn -of_objects [ipx::current_core]]
set_property physical_name sn_TREADY [ipx::get_port_maps TREADY -of_objects [ipx::get_bus_interfaces sn -of_objects [ipx::current_core]]]

# Add info for "N" parameter
set_property tooltip {Number of parallel packetfilter cores} [ipgui::get_guiparamspec -name "N" -component [ipx::current_core] ]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "N" -component [ipx::current_core] ]

# Add info for packet mem bytes parameter
set_property display_name {Maximum packet size in bytes} [ipgui::get_guiparamspec -name "PACKET_MEM_BYTES" -component [ipx::current_core] ]
set_property tooltip {Will be used to generate internal buffers. Will be internally rounded up to a power of 2, but soon this will be fixed} [ipgui::get_guiparamspec -name "PACKET_MEM_BYTES" -component [ipx::current_core] ]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "PACKET_MEM_BYTES" -component [ipx::current_core] ]

# Add info for instruction mem depth parameter
set_property display_name {Maximum number of instructions} [ipgui::get_guiparamspec -name "INST_MEM_DEPTH" -component [ipx::current_core] ]
set_property tooltip {This will be rounded up internally to a power of 2. Sets the size of the instruction memory} [ipgui::get_guiparamspec -name "INST_MEM_DEPTH" -component [ipx::current_core] ]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "INST_MEM_DEPTH" -component [ipx::current_core] ]

# Add info for buf in parameter
set_property display_name {Enable buffering in BRAM Inputs} [ipgui::get_guiparamspec -name "BUF_IN" -component [ipx::current_core] ]
set_property tooltip {Enable this if really having trouble meeting timing} [ipgui::get_guiparamspec -name "BUF_IN" -component [ipx::current_core] ]
set_property widget {checkBox} [ipgui::get_guiparamspec -name "BUF_IN" -component [ipx::current_core] ]
set_property value true [ipx::get_user_parameters BUF_IN -of_objects [ipx::current_core]]
set_property value true [ipx::get_hdl_parameters BUF_IN -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_user_parameters BUF_IN -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_hdl_parameters BUF_IN -of_objects [ipx::current_core]]

# Add info for buf out parameter
set_property display_name {Enable buffering in BRAM outputs} [ipgui::get_guiparamspec -name "BUF_OUT" -component [ipx::current_core] ]
set_property tooltip {Only disable this if you think you can get away with it} [ipgui::get_guiparamspec -name "BUF_OUT" -component [ipx::current_core] ]
set_property widget {checkBox} [ipgui::get_guiparamspec -name "BUF_OUT" -component [ipx::current_core] ]
set_property value true [ipx::get_user_parameters BUF_OUT -of_objects [ipx::current_core]]
set_property value true [ipx::get_hdl_parameters BUF_OUT -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_user_parameters BUF_OUT -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_hdl_parameters BUF_OUT -of_objects [ipx::current_core]]

# Add info for pessimistic mode parameter
set_property display_name {Enable pessimistic registers} [ipgui::get_guiparamspec -name "PESS" -component [ipx::current_core] ]
set_property tooltip {If you are really desperate, this option enables several extra registers to help ease timing} [ipgui::get_guiparamspec -name "PESS" -component [ipx::current_core] ]
set_property widget {checkBox} [ipgui::get_guiparamspec -name "PESS" -component [ipx::current_core] ]
set_property value false [ipx::get_user_parameters PESS -of_objects [ipx::current_core]]
set_property value false [ipx::get_hdl_parameters PESS -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_user_parameters PESS -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_hdl_parameters PESS -of_objects [ipx::current_core]]

# Remove option to futz with AXI Lite address width
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "AXI_ADDR_WIDTH" -component [ipx::current_core]]

# Actually create the IP
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project 
exit




