#!/bin/bash

# A little script to package the HLS chopper code as an IP

# First test if vivado is on the path
which vivado_hls 2>/dev/null >/dev/null

if [ $? -ne 0 ]; then
    echo "Please ensure vivado_hls is on your path"
else
    vivado_hls hls.tcl "chopper" "xczu19eg-ffvc1760-2-i" "3.103"
    rm -f *.log
fi
