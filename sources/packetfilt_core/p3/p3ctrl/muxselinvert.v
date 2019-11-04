`timescale 1ns / 1ps
/*
muxselinvert.v

I'm really going off the deep end here. I just spent like 30 minutes drawing K-maps
like a schmuck! 

This module is part of packetmem.v. It converts the mux selections for SN, CPU, and
FWD to the corresponing "inverse" selections for ping, pang, and pung.

Basically, this is here to implement the rule that:
"If agent A selects buffer P, then buffer P selects agent A"

See the file kmaps.csv in this repository
*/


module muxselinvert(
	input wire [1:0] sn_sel,
	input wire [1:0] cpu_sel,
	input wire [1:0] fwd_sel,
	
	output wire [1:0] ping_sel,
	output wire [1:0] pang_sel,
	output wire [1:0] pung_sel
);

//Yes, I really did draw a bunch of K-maps. What's it to you????

assign ping_sel[1] = 	(~fwd_sel[1] & fwd_sel[0]) | (
						(~cpu_sel[1] & cpu_sel[0]) &
						 (sn_sel[1] | ~sn_sel[0])
						); 
assign ping_sel[0] = 	(~fwd_sel[1] & fwd_sel[0]) | 
						(~sn_sel[1] & sn_sel[0]);

assign pang_sel[1] =	(fwd_sel[1] & ~fwd_sel[0]) |
						(cpu_sel[1] & ~cpu_sel[0]);

assign pang_sel[0] =	(fwd_sel[1] & ~fwd_sel[0]) |
						(sn_sel[1] & ~sn_sel[0]);

assign pung_sel[1] = 	(fwd_sel[1] & fwd_sel[0]) | (
						(cpu_sel[1] & cpu_sel[0]) &
						 (~sn_sel[1] | ~sn_sel[0])
						); 

assign pung_sel[0] = 	(fwd_sel[1] & fwd_sel[0]) | 
						(sn_sel[1] & sn_sel[0]);
/*
Ping select bit 1 = F'W+C'P(S+N')

Ping select bit 0 = F'W+S'N

Pang select bit 1 = FW'+CP'

Pang select bit 0 = FW'+SN'

Pung select bit 1 = FW+CP(S'+N')

Pung select bit 0 = FW+SN

*/

endmodule
