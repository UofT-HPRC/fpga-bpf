`timescale 1ns / 1ps

/*

stage1.v

Implements the decode stage. Also responsible for a few datapath signals:
        - B_sel, ALU_sel, ALU_en
        - addr_sel, rd_en
        - regfile_sel, regfile_wr_en
        - imm_stage1
    
This is the most complicated stage, since it must also deal with buffered 
handshaking.

*/

`ifdef FROM_CONTROLLER
`include "../../bpf_defs.vh"
`else /* For Vivado */
`include "bpf_defs.vh"
`endif

module stage1 (
    input wire clk,
    input wire rst,
    
    input wire [63:0] inst,
    input wire branch_mispredict,
    
    //Outputs from this stage:
    output wire B_sel,
    output wire [3:0] ALU_sel,
    output wire ALU_en,
    output wire addr_sel,
    output wire rd_en,
    output wire regfile_sel,
    output wire regfile_wr_en,
    output wire imm_stage1,
    
    //Outputs for next stage (registered in this module):
    output wire [7:0] opcode,
    output wire [1:0] PC_sel,
    output wire PC_en,
    output wire A_sel,
    output wire A_en,
    output wire X_sel,
    output wire X_en,
    output wire imm,
    output wire jt,
    output wire jf,
    
    //Handshaking signals
    input wire prev_vld,
    output wire rdy,
    input wire next_rdy,
    output wire vld
);



endmodule
