default:	cpu_adapter.vcd

cpu_adapter.vcd:	cpu_adapter.vvp
	vvp cpu_adapter.vvp

cpu_adapter.vvp:	cpu_adapter_tb.v cpu_adapter.v cpu_adapter_drivers.mem
	iverilog -DFROM_CPUADAPTER -g2012 -o cpu_adapter.vvp cpu_adapter_tb.v

open:	cpu_adapter.vcd
	gtkwave cpu_adapter.vcd --autosavename &

clean:
	rm -rf cpu_adapter.vvp
	rm -rf cpu_adapter.vcd
