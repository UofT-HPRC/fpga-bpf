MODULE := fwd_width_adapter

default:	$(MODULE).vcd

$(MODULE).vcd:	$(MODULE).vvp
	vvp $(MODULE).vvp

$(MODULE).vvp:	$(MODULE).v $(MODULE)_tb.v
	iverilog -Wall -Wno-timescale -DICARUS_VERILOG -g2012 -o $(MODULE).vvp $(MODULE)_tb.v

open:	$(MODULE).vcd
	gtkwave $(MODULE).vcd --autosavename &

clean:
	rm -rf $(MODULE).vvp
	rm -rf $(MODULE).vcd

force:
	touch $(MODULE)_tb.v
	make

syntax_check:
	iverilog -Wall -g2012 -o tmp.vvp $(MODULE).v
	rm -rf tmp.vvp
