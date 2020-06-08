Copyright 2020 Juan Camilo Vega. This file is part of the fpga-bpf 
project, whose license information can be found at 
https://github.com/UofT-HPRC/fpga-bpf/blob/master/LICENSE


=======
CHOPPER
=======

Author: Juan Camilo Vega

This HLS core takes in a single high-speed AXI Stream and splits it into 
several streams, which can be clocked at a slower frequency. 

Specifics:
    - The core uses a round-robin scheme
    - The core will only arbitrate on TLAST


=============
CONFIGURATION
=============

To change the number of output streams, simply edit the the divisors value in 
src/parameter_vals.h.


============
BASIC WIRING
============

The core expects each output stream to go into a FIFO. Here are the messages 
Camilo sent me over Slack to explain how to wire it up:

    These are the new HLS script files. I also found another issue where in a very 
    specific edge case it can't keep up with 100G so I applied a fix but it changes 
    how the external fifos are configured.

    Now I need them to have a depth of 64 and in the flags I need to enable 
    programmable full, almost empty, and programmable full threshold needs to be 
    set as 35

    Also all the Programmable full flags need to be concated together and passed 
    through a utility vector logic configured as not of the appropriate size before 
    looping back to the arbiter (edited) 

    Mathematically, the new arbitration equation is (in C++ logic) empty_bf= 
    (empty==0) ? ((nfull==0)?(ap_uint<18> (0x3FFFF)):nfull):empty;

    where for each case it asks if (!arb_1_out.full() && (empty_bf.bit(0)))

    The idea is that if there is any empty fifos then empty != 0 so empty_bf has a 
    1 on the bits corresponding to empty fifos, the chain of ifs will then select 
    one of those

    If none are empty then the nfull bit indicates the fifo has stuff (bad for 
    latency) but is empty enough to fit a whole packet

    So if empty is 0 (none are empty) but nfull is not zero then empty_bf would 
    equal nfull with the same logic

    Otherwise in the case that is impossible unless the data provided is faster 
    than 100Gbps, if empty and nfull are both zeros (meaning no fifo has enough 
    space for the max size packet, then it selects any of them since we can't do 
    more at that point

    35 is set as 64 (size of flag) - 25 (max packet size in 512bit flits, 64 * 25 = 
    1600B) - 1 (delay in the arbiter to communicate full info) - 3 (max delay in 
    the fifo to raise the programmable full flag according to its spec) = 35
