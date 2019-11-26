default:	p_ng.vcd

p_ng.vcd:	p_ng.vvp
	vvp p_ng.vvp

p_ng.vvp:	p_ng.v p_ng_tb.v p_ng_drivers.mem
	iverilog -DFROM_P_NG -g2012 -o p_ng.vvp p_ng_tb.v

open:	p_ng.vcd
	gtkwave p_ng.vcd --autosavename &

clean:
	rm -rf p_ng.vvp
	rm -rf p_ng.vcd
