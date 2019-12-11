# Copied from Clark's traffic generator project.

# Call this script as 
# vivado_hls hls.tcl module_name part_name period

set module_name [lindex $argv 0]
set part_name [lindex $argv 1]
set period [lindex $argv 2]
open_project $module_name
set_top $module_name
add_files src/$module_name.cpp -cflags "-I include"
#add_files -tb src/${module_name}_test.cpp
open_solution "solution1"
set_part $part_name -tool vivado
create_clock -period $period -name default
config_rtl -reset all
config_interface -register_io off
#csim_design -clean
csynth_design
export_design
