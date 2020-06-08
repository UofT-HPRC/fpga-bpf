Copyright 2020 Marco Merlini. This file is part of the fpga-bpf project,
whose license information can be found at 
https://github.com/UofT-HPRC/fpga-bpf/blob/master/LICENSE


This is a really simple little program to generate bpf machine code files. It
will print the machine code in hex, and save a binary file called prog.bpf

I should really get around to cleaning up this code and makign it more usable.

To compile, make sure libpcap is installed, and run

    gcc -o compilefilt compilefilt.c -lpcap
