`timescale 1ns / 1ps

/*
stage0.v

Implements the fetch stage of the pipelined controller
*/

module stage0 (
    input wire clk,
    input wire rst,

    input wire branch_mispredict,
    output wire inst_rd_en,
    output wire PC_en,
    
    input wire next_rdy,
    output wire vld
);

    //If next stage is ready, we can read an instruction
    //However, if the branch_mispredict signal is asserted, it means PC is being
    //changed on this cycle, and we should wait
    
    assign inst_rd_en = next_rdy && !branch_mispredict;
    assign PC_en = inst_rd_en;
    
    reg vld_r = 0;
    always @(posedge clk) begin
        if (rst || branch_mispredict) vld_r <= 0;
        else vld_r <= inst_rd_en;
    end
    
    assign vld = vld_r;
    
endmodule
