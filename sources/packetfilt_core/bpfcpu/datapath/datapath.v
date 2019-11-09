`timescale 1ns / 1ps

/*
datapath.v

    - A_sel, A_en
    - X_sel, X_en
    - PC_sel, PC_en
    - B_sel, ALU_sel, ALU_en
    - regfile_sel, regfile_wr_en
    - addr_sel
    - packet_len
    - imm
    - jt, jf

*/

/*
TODO LIST:

Move `defines to a header file
Implement ALU
Copy over old regfile code; there is nothing wrong with it
Write up new PC code
Whatever other small jobs are left

*/


//Named constants for A and X MUXes
`include "bpf_defs.vh"

module datapath # (
    parameter BYTE_ADDR_WIDTH = 12,
    parameter CODE_ADDR_WIDTH = 10
) (
    input wire clk,
    input wire rst,
    
    input wire [2:0] A_sel,
    input wire A_en,
    
    input wire [2:0] X_sel,
    input wire X_en,
    
    input wire [1:0] PC_sel,
    input wire PC_en,
    output wire [CODE_ADDR_WIDTH-1:0] inst_rd_addr,
    
    input wire B_sel,
    input wire [3:0] ALU_sel,
    input wire ALU_en,
    output wire [3:0] ALU_flags,
    output wire ALU_vld,
    
    input wire regfile_sel,
    input wire regfile_wr_en,
    
    input wire addr_sel,
    output wire [BYTE_ADDR_WIDTH-1:0] rd_addr,
    input wire [31:0] packet_data,
    
    input wire [31:0] packet_len,
    
    input wire [31:0] imm_stage1,
    input wire [31:0] imm_stage2,
    
    input wire [7:0] jt,
    input wire [7:0] jf
);

    //Forward-declare wires
    wire [31:0] regfile_odata;
    wire [31:0] ALU_out;
    
    //Accumulator's new value
    always @(posedge clk) begin
        if (A_en == 1'b1) begin
            case (A_sel)
                `A_SEL_IMM:
                    A <= imm_stage2; //Note use of imm_stage2
                `A_SEL_ABS:
                    A <= packet_data;
                `A_SEL_IND:
                    A <= packet_data; //Hmmmm... both ABS and IND addressing wire packet_data to A
                `A_SEL_MEM:
                    A <= regfile_odata; 
                `A_SEL_LEN:
                    A <= packet_len;
                `A_SEL_MSH:
                    A <= {26'b0, imm_stage2[3:0], 2'b0}; //TODO: No MSH instruction is defined (by bpf) for A. Should I leave this?
                `A_SEL_ALU:
                    A <= ALU_out;
                `A_SEL_X: //for TXA instruction
                    A <= X;
            endcase
        end
    end

    //Auxiliary (X) register's new value
    always @(posedge clk) begin
        if (X_en == 1'b1) begin
            case (X_sel)
                `X_SEL_IMM:
                    X <= imm_stage2; //Note use of imm_stage2
                `X_SEL_ABS:
                    X <= packet_data;
                `X_SEL_IND:
                    X <= packet_data; //Hmmmm... both ABS and IND addressing wire packet_data to X
                `X_SEL_MEM:
                    X <= regfile_odata;
                `X_SEL_LEN:
                    X <= packet_len;
                `X_SEL_MSH:
                    X <= {26'b0, packet_data[3:0], 2'b0};
                `X_SEL_A: //for TAX instruction
                    X <= A;
                default:
                    X <= 0; //Does this even make sense?
            endcase
        end
    end

endmodule
