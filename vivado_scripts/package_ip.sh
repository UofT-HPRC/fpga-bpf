#!/bin/bash

# A little script to assemble the packet filter as an IP

# First test if vivado is on the path
which vivado 2>/dev/null >/dev/null

if [ $? -ne 0 ]; then
    echo "Please ensure vivado is on your path"
else
	rm -rf $1
    mkdir -p $1/src
    cp $(find ../sources -name "*.v" -o -name "*vh" -o -name "*sv" | grep -v "tb" | grep -v "template") $1/src
    vivado -nolog -nojournal -notrace -mode batch -source ip_maker.tcl -tclargs $1 $2
    rm -rf "$1_ip"
fi
