default:	alu.vcd

alu.vcd:	alu.vvp
	vvp alu.vvp

alu.vvp:	alu.v alu_tb.v alu_drivers.mem
	iverilog -DFROM_ALU -g2012 -o alu.vvp alu_tb.v

open:	alu.vcd
	gtkwave alu.vcd --autosavename &

clean:
	rm -rf alu.vvp
	rm -rf alu.vcd

force:
	touch alu_tb.v
	make
