default:	p3.vcd

p3.vcd:	p3.vvp
	vvp p3.vvp

p3.vvp:	p3.v p3_tb.v p3_drivers.mem
	iverilog -DFROM_P3 -g2012 -o p3.vvp p3_tb.v

open:	p3.vcd
	gtkwave p3.vcd --autosavename &

clean:
	rm -rf p3.vvp
	rm -rf p3.vcd

force:
	touch p3_tb.v
	make
