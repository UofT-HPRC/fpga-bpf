MODULE := axistream_packetfilt
MODULE_CAPS := AXISTREAM_PACKETFILT
VERILOG_INCLUDE = -Iforwarders/axistream_forwarder/fwd_width_adapter
VERILOG_INCLUDE += -Isnoopers/axistream_snooper/sn_width_adapter

default:	$(MODULE).vcd

$(MODULE).vcd:	$(MODULE).vvp
	vvp $(MODULE).vvp

$(MODULE).vvp:	$(MODULE).v $(MODULE)_tb.v $(MODULE)_drivers.mem
	iverilog -Wall -Wno-timescale -DICARUS_VERILOG -DFROM_$(MODULE_CAPS) $(VERILOG_INCLUDE) -g2012 -o $(MODULE).vvp $(MODULE)_tb.v

open:	$(MODULE).vcd
	gtkwave $(MODULE).vcd --autosavename &

clean:
	rm -rf $(MODULE).vvp
	rm -rf $(MODULE).vcd

force:
	touch $(MODULE)_tb.v
	make
