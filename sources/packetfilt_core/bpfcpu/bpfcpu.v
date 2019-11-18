`timespec 1ns / 1ps

/*

bpfcpu.v

Wires together the controller and the datapath. Also handles handshaking 
signals with P3 controller

TODO: handshaking with P3

TODO: have someone set mem_vld. Either have an internal counter in controller 
based on the parameters, or output it from the packet memory.

*/

`ifdef FROM_BPFCPU
`include "controller/controller.v"
`include "datapath/datapath.v"
`endif

module bpfcpu # (
    parameter BYTE_ADDR_WIDTH = 12,
    parameter PLEN_WIDTH = 32,
    parameter CODE_ADDR_WIDTH = 10,
    parameter CODE_DATA_WIDTH = 64,
    parameter PESS = 0
) (
    input wire clk,
    input wire rst,

    //Interface to P3
    input wire cpu_done_ack,
    input wire rdy_for_cpu,
    input wire cache_hit,
    input wire [31:0] cached_data,
    input wire [31:0] resized_mem_data, 
    input wire [PLEN_WIDTH-1:0] cpu_byte_len,
    
    output wire [BYTE_ADDR_WIDTH-1:0] byte_rd_addr,
    output wire cpu_rd_en,
    output wire [1:0] transfer_sz,
    output wire cpu_acc,
    output wire cpu_rej,
    output wire rdy_for_cpu_ack,
    
    //Interface to intruction memory
    output wire [CODE_ADDR_WIDTH-1:0] inst_rd_addr;
    output wire inst_rd_en,
    input wire [CODE_DATA_WIDTH-1:0] instr_in

);
    
    //Controller outputs
    wire PC_en;
    wire B_sel;
    wire [3:0] ALU_sel;
    wire ALU_en;
    wire addr_sel;
    wire regfile_wr_en;
    wire imm_stage1;
    wire [CODE_ADDR_WIDTH-1:0] jt;
    wire [CODE_ADDR_WIDTH-1:0] jf;
    wire [1:0] PC_sel; 
    wire A_sel;
    wire A_en;
    wire X_sel;
    wire X_en;
    wire [3:0] regfile_sel;
    wire [31:0] imm_stage2;
    wire [CODE_ADDR_WIDTH-1:0] jmp_correction;
    
    //Datapath outputs
    wire eq;
    wire gt;
    wire ge;
    wire set;
    wire ALU_vld;

    controller # (
        .CODE_ADDR_WIDTH(CODE_ADDR_WIDTH),
        .PESS(PESS)
    ) ctrl (
        .clk(clk),
        .rst(rst),
        .eq(eq),
        .gt(gt),
        .ge(ge),
        .set(set),
        .ALU_vld(ALU_vld),
        .instr_in(instr_in),
        .mem_vld(mem_vld), //TODO (see comments at top of module)
        .inst_rd_en(inst_rd_en),
        .rd_en(cpu_rd_en),
        .acc(cpu_acc),
        .rej(cpu_rej),
        .PC_en(PC_en),
        .B_sel(B_sel),
        .ALU_sel(ALU_sel),
        .ALU_en(ALU_en),
        .addr_sel(addr_sel),
        .regfile_wr_en(regfile_wr_en),
        .imm_stage1(imm_stage1),
        .jt(jt),
        .jf(jf),
        .PC_sel(PC_sel), 
        .A_sel(A_sel),
        .A_en(A_en),
        .X_sel(X_sel),
        .X_en(X_en),
        .regfile_sel(regfile_sel),
        .imm_stage2(imm_stage2),
    );

    datapath # (
        .BYTE_ADDR_WIDTH(BYTE_ADDR_WIDTH),
        .CODE_ADDR_WIDTH(CODE_ADDR_WIDTH),
        .PLEN_WIDTH(PLEN_WIDTH)
    ) dpath (
        .clk(clk),
        .rst(rst),
        .A_sel(A_sel),
        .A_en(A_en),
        .X_sel(X_sel),
        .X_en(X_en),
        .PC_sel(PC_sel),
        .PC_en(PC_en),
        .inst_rd_addr(inst_rd_addr),
        .B_sel(B_sel),
        .ALU_sel(ALU_sel),
        .ALU_en(ALU_en),
        .eq(eq),
        .gt(gt),
        .ge(ge),
        .set(set),
        .ALU_vld(ALU_vld),
        .regfile_sel(regfile_sel),
        .regfile_wr_en(regfile_wr_en),
        .addr_sel(addr_sel),
        .packet_rd_addr(byte_rd_addr),
        .packet_data(resized_mem_data), //TODO: add caching to cpu_adapter
        .packet_len(cpu_byte_len),
        .imm_stage1(imm_stage1),
        .imm_stage2(imm_stage2),
        .jt(jt),
        .jf(jf),
        .jmp_correction(jmp_correction)
    );

endmodule
