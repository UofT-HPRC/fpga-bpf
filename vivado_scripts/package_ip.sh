#!/bin/bash

# A little script to assemble the packet filter as an IP

# First test if vivado is on the path
which vivado 2>/dev/null >/dev/null

if [ $? -ne 0 ]; then
    echo "Please ensure vivado is on your path"
else
    rm -rf tmp
    mkdir tmp
    cp $(find ../sources -name "*.v" | grep -v "tb") tmp/
    vivado -nolog -nojournal -notrace -mode batch -source ip_maker.tcl -tclargs packetfilt "xczu19eg-ffvc1760-2-i"
fi
