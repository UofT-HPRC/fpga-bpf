MODULE := axistream_forwarder
MODULE_CAPS := AXISTREAM_FORWARDER

default:	$(MODULE).vcd

$(MODULE).vcd:	$(MODULE).vvp
	vvp $(MODULE).vvp

$(MODULE).vvp:	$(MODULE).v $(MODULE)_tb.v $(MODULE)_drivers.mem
	iverilog -DFROM_$(MODULE_CAPS) -g2012 -o $(MODULE).vvp $(MODULE)_tb.v

open:	$(MODULE).vcd
	gtkwave $(MODULE).vcd --autosavename &

clean:
	rm -rf $(MODULE).vvp
	rm -rf $(MODULE).vcd

force:
	touch $(MODULE)_tb.v
	make

syntax_check: $(MODULE).v
	iverilog -DICARUS_VERILOG -Ifwd_width_adapter/ -g2012 -Wall -Wno-timescale -o tmp.vvp $(MODULE).v
	rm -rf tmp.vvp
