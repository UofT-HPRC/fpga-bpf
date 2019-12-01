# Copied from Clark's traffic generator project

include config.mk
# config.mk includes all the environment variables used by the scripts in the
# scripts folder. It was copied from Clark's traffic generator project and then
# modified to match current project

all: clean
	# Package IP nicely using Vivado
	./package_ip.sh $(ip_name) $(part_name)
	# Clean up after Vivado...
	./pick_up_vivados_dirty_socks.sh
clean:
	rm -rf tmp
	rm -rf $(ip_name)_ip
