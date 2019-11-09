`timescale 1ns / 1ps

/*

stage2.v

Implements the writeback stage. Can assert the branch_mispredict signal. 
Depending on the opcode, this stage may wait for a valid signal on the memory 
or ALU.

This stage also takes care of decrementing jt and jf (see the README in this 
folder)

*/

`ifdef FROM_CONTROLLER
`include "../../bpf_defs.vh"
`else /* For Vivado */
`include "bpf_defs.vh"
`endif

module stage2 (
    input wire clk,
    input wire rst,

);


endmodule
