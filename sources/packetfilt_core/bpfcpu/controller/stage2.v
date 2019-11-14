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

    //Inputs from last stage:
    input wire [7:0] opcode,
    input wire jt,
    input wire jf,
    input wire imm,
    
    //Inputs from datapath:
    input wire mem_vld,
    input wire eq,
    input wire gt,
    input wire ge,
    input wire set,
    input wire ALU_vld,
    
    //Outputs for this stage:
    output wire [1:0] PC_sel,
    output wire PC_en,
    output wire A_sel,
    output wire A_en,
    output wire X_sel,
    output wire X_en,
    output wire [31:0] imm_stage2,
    output wire branch_mispredict,
    
    //count number of cycles instruction has been around for
    input wire [5:0] icount,
    output wire [5:0] ocount,
    
    //Handshaking signals
    input wire prev_vld,
    output wire rdy
);


endmodule
