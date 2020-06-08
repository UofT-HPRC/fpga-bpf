#!/bin/bash

# Copyright 2020 Marco Merlini. This file is part of the fpga-bpf project,
# whose license information can be found at 
# https://github.com/UofT-HPRC/fpga-bpf/blob/master/LICENSE


# Vivado leaves a bunch of crap laying around that no one cares about. So
# delete it

rm -f *log
rm -rf .Xil
rm -f vivado*
