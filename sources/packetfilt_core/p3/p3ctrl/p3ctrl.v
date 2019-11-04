`timescale 1ns / 1ps
`include "snqueue.v"
`include "cpuqueue.v"
`include "fwdqueue.v"
`include "muxselinvert.v"


//These files are mostly copied from my old code, but there are some minor 
//differences:
// - I moved the muxselinverter to this module, since it made more sense
// - I added handshaking for the ready and done signals. It was giving me a 
//   major headache when it came time to start adding delay stages here and 
//   there

/*
p3ctrl.v

This is a "ping-pang-pung" controller. The idea is as follows:
We have three agents that all need to share memory. To make it possible
for all three to run concurrently, we need three buffers. 

In a ping-pong scheme, the controller is fairly simple. Say the agents are
named A and B, and the buffers are name Ping and Pong. Say Ping is being
controlled by A, and Pong is being controlled by B. If A finishes its work,
it gets disconnected from Ping and we wait for B to finish. Once B finishes,
then we wire B to Ping and A to Pong and both can start. (If they finish at
the same time, we skip the states where A waits for B).

However, in a ping-pang-pong scheme, the controller is significantly more
complicated. Suppose the connections are (A-ping), (B-pang), (C-pong). Now
if B finishes first, we have to wait for C to finish. But when C finishes,
we have to wait for A to finish? And what if A finishes before C?
Yes, we both know what should happen in these cases, but writing something
in Verilog to deal with all this spaghetti logic (while trying to keep it
reasonably simple/performant/easy to debug) is quite challenging.

So here is the strategy:

Each agent (in our specific case, the snooper, CPU, and forwarder) will 
have a queue of "jobs" (i.e. [pointers to] buffers to operate on). When one 
agent is finished (e.g. the snooper) it will enqueue [a pointer to] the buffer 
it has just processed to the jobs on the next agent's queue (e.g. the CPU).

For this purpose, I wrote up snqueue.v, cpuqueue.v, and fwdqueue.v. They are
the aforementioned "job queues".

This module is intended to be used to generate the select lines on the MUXes
in packetmem.v (in order to wire up certain packetrams to certain agents).
*/

//TODO: figure out a clean way to add handshaking

module p3_ctrl(
	input wire clk,
	input wire rst,
	input wire A_done,
	input wire B_acc, //Special case for me: B can "accept" a memory buffer and send it to C
	input wire B_rej, //or it can "reject" it and send it back to A
	input wire C_done,
	
	output wire [1:0] sn_sel,
	output wire [1:0] cpu_sel,
	output wire [1:0] fwd_sel,
    
    output wire [1:0] ping_sel,
    output wire [1:0] pang_sel,
    output wire [1:0] pong_sel
);

muxselinvert muxthing(
	.sn_sel(sn_sel),
	.cpu_sel(cpu_sel),
	.fwd_sel(fwd_sel),
	.ping_sel(ping_sel),
	.pang_sel(pang_sel),
	.pung_sel(pung_sel)
);

snqueue snq(
	.clk(clk),
	.rst(rst),
	.token_from_cpu(cpu_sel),
	.en_from_cpu(B_rej),
	.token_from_fwd(fwd_sel),
	.en_from_fwd(C_done),
	.deq(A_done),
	.head(sn_sel)
);

cpuqueue cpuq(
	.clk(clk),
	.rst(rst),
	.token_from_sn(sn_sel),
	.en_from_sn(A_done),
	.deq(B_acc | B_rej),
	.head(cpu_sel)
);

fwdqueue fwdq (
	.clk(clk),
	.rst(rst),
	.token_from_cpu(cpu_sel),
	.en_from_cpu(B_acc),
	.deq(C_done),
	.head(fwd_sel)
);

endmodule
