# Copied from Clark's traffic generator project
# Modified to match the particular project

# Call as:
# vivado -mode tcl -nolog -nojournal -source scripts/ip_package.tcl -tclargs $ip_name $part_name


# INSTRUCTIONS
# ------------
# The first time you run this tcl, it will open the Vivado GUI in the IP 
# packaging mode. Go ahead and edit your IP the way you normally would, taking 
# care to copy and paste all the TCL commands that Vivado generates into the
# location labeled below.
# When you're finished, remove the "start_gui" line and uncomment all the lines
# at the end of this script


start_gui; # Remove this line after copying TCL commands

set ip_name [lindex $argv 0]
set part_name [lindex $argv 1]
set project_name ${ip_name}_ip
create_project ${project_name} ${project_name} -part $part_name
import_files tmp/
ipx::package_project -root_dir ${project_name}/${project_name}.srcs/sources_1/imports -vendor Marco_Merlini -library fpga_bpf -taxonomy /UserIP

# start GUI

###PUT_YOUR_COMMANDS_HERE

# done with GUI


# Uncomment these lines after copying TCL commands from gui

###ipx::create_xgui_files [ipx::current_core]
###ipx::update_checksums [ipx::current_core]
###ipx::save_core [ipx::current_core]
###close_project 
###exit




