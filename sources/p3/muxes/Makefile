default:	muxes.vcd

muxes.vcd:	muxes.vvp
	vvp muxes.vvp

muxes.vvp:	muxes.v muxes_tb.v muxes_drivers.mem
	iverilog -g2012 -o muxes.vvp muxes_tb.v

open:	muxes.vcd
	gtkwave muxes.vcd --autosavename &

clean:
	rm -rf muxes.vvp
	rm -rf muxes.vcd
