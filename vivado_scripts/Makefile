# Copied from Clark's traffic generator project

include config.mk
# config.mk includes all the environment variables used by the scripts in the
# scripts folder. It was copied from Clark's traffic generator project and then
# modified to match current project

all: clean
	# Package IP nicely using Vivado
	vivado -mode tcl -nolog -nojournal -source scripts/ip_maker.tcl -tclargs $(ip_name) $(part_name)
	# Clean up after Vivado...
	scripts/pick_up_vivados_dirty_socks.sh
clean:
	rm -rf tmp
	rm -rf $(ip_name)_ip
