default:	sn_adapter.vcd

sn_adapter.vcd:	sn_adapter.vvp
	vvp sn_adapter.vvp

sn_adapter.vvp:	sn_adapter_tb.v sn_adapter.v sn_adapter_drivers.mem
	iverilog -g2012 -o sn_adapter.vvp sn_adapter_tb.v

open:	sn_adapter.vcd
	gtkwave sn_adapter.vcd --autosavename &

clean:
	rm -rf sn_adapter.vvp
	rm -rf sn_adapter.vcd
