#!/bin/bash

# A little script to help rebuild the vivado project

# First test if vivado is on the path
which vivado 2>/dev/null >/dev/null

if [ $? -ne 0 ]; then
    echo "Please ensure vivado is on your path"
else
    vivado -nolog -nojournal -notrace -mode batch -source proj.tcl
fi
