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
    
    //count number of cycles instruction has been around for
    input wire [5:0] icount,
    output wire [5:0] ocount,
    
    //Handshaking signals
    input wire prev_vld,
    output wire rdy,
    input wire next_rdy,
    output wire vld
);
    
    //Start with the easy stuff: subfields of the instruction:
    assign opcode = inst[55:48];
    assign jt = inst[47:40];
    assign jf = inst[39:32];
    assign imm = inst[31:0];
    assign imm_stage1 = imm;
    
        //Named subfields of the opcode (used internally to neaten the code)
        wire [2:0] opcode_class;
        assign opcode_class = opcode[2:0];
        wire [2:0] addr_type;
        assign addr_type = opcode[7:5];
        wire [2:0] jmp_type;
        assign jmp_type = opcode[6:4];
        wire [4:0] miscop;
        assign miscop = opcode[7:3];
        wire [1:0] retval;
        assign retval = opcode[4:3];
    
    //More easy stuff: a lot of control signals come straight from opcode bits
    assign B_sel = opcode[3];
    assign ALU_sel = opcode[7:4];
    
    //The rest of it requires us to look at the opcode and make decisions. This
    //is my best attempt at keeping the code legible...
    assign addr_sel = (addr_type == `BPF_IND) ? `PACK_ADDR_IND : `PACK_ADDR_ABS;
    
    always @(*) begin
        if ((opcode_class == `BPF_LD) && (addr_type == `BPF_ABS || addr_type == `BPF_IND)) begin
            rd_en <= 1;
        end else if ((opcode_class == `BPF_LDX) && (addr_type == `BPF_ABS || addr_type == `BPF_IND || addr_type == `BPF_MSH)) begin
            rd_en <= 1;
        end else begin
            rd_en <= 0;
        end
    end
    
    assign regfile_sel_decoded = (opcode_class == `BPF_STX) ? `REGFILE_IN_X : `REGFILE_IN_A;
    assign regfile_wr_en_decoded = (opcode_class == `BPF_ST || opcode_class == `BPF_STX);

endmodule
