`timescale 1ns / 1ps
`include "queues/snqueue.v"
`include "queues/cpuqueue.v"
`include "queues/fwdqueue.v"
`include "muxselinvert/muxselinvert.v"


//These files are mostly copied from my old code, but there are some minor 
//differences:
// - I moved the muxselinverter to this module, since it made more sense
// - I added handshaking for the ready and done signals. It was giving me a 
//   major headache when it came time to start adding delay stages here and 
//   there, and I hoe handshaking is the solution

/*
p3ctrl.v

Wires up the job queues into one module, and also produces all the MUX signals
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
