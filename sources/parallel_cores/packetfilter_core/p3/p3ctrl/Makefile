default:	p3ctrl.vcd

p3ctrl.vcd:	p3ctrl.vvp
	vvp p3ctrl.vvp

p3ctrl.vvp:	p3ctrl_tb.v p3ctrl.v p3ctrl_drivers.mem
	iverilog -DFROM_P3CTRL -g2012 -o p3ctrl.vvp p3ctrl_tb.v

open:	p3ctrl.vcd
	gtkwave p3ctrl.vcd --autosavename &

clean:
	rm -rf p3ctrl.vvp
	rm -rf p3ctrl.vcd
