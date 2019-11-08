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

    //Named constants for A register MUX
    `ifndef A_SEL_IMM
    `define		A_SEL_IMM 	3'b000
    `endif 
    `define		A_SEL_ABS	3'b001
    `define		A_SEL_IND	3'b010 
    `define		A_SEL_MEM	3'b011
    `define		A_SEL_LEN	3'b100
    `define		A_SEL_MSH	3'b101
    `define		A_SEL_ALU	3'b110
    `define		A_SEL_X		3'b111
    //Accumulator's new value
    always @(posedge clk) begin
        if (A_en == 1'b1) begin
            case (A_sel)
                3'b000:
                    A <= imm_stage2; //Note use of imm_stage2
                3'b001:
                    A <= packet_data;
                3'b010:
                    A <= packet_data; //Hmmmm... both ABS and IND addressing wire packet_data to A
                3'b011:
                    A <= scratch_odata; 
                3'b100:
                    A <= packet_len;
                3'b101:
                    A <= {26'b0, imm3[3:0], 2'b0}; //TODO: No MSH instruction is defined (by bpf) for A. Should I leave this?
                3'b110:
                    A <= ALU_out;
                3'b111: //for TXA instruction
                    A <= X;
            endcase
        end
    end

    //Named constants for X register MUX
    `define		X_SEL_IMM 	3'b000 
    `define		X_SEL_ABS	3'b001
    `define		X_SEL_IND	3'b010 
    `define		X_SEL_MEM	3'b011
    `define		X_SEL_LEN	3'b100
    `define		X_SEL_MSH	3'b101
    `define		X_SEL_A		3'b111
    //Auxiliary (X) register's new value
    always @(posedge clk) begin
        if (X_en == 1'b1) begin
            case (X_sel)
                `X_SEL_IMM:
                    X <= imm3; //Note use of imm3
                `X_SEL_ABS:
                    X <= packet_data;
                `X_SEL_IND:
                    X <= packet_data; //Hmmmm... both ABS and IND addressing wire packet_data to X
                `X_SEL_MEM:
                    X <= scratch_odata;
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
