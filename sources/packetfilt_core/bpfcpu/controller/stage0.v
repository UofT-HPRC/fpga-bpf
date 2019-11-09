`timescale 1ns / 1ps

/*
stage0.v

Implements the fetch stage of the pipelined controller
*/

module stage0 (
    input wire clk,
    input wire rst,

    input wire branch_mispredict,
    output wire rd_en,
    output wire PC_en,
    
    input wire next_rdy,
    output wire vld
);

    //If next stage is ready, we can read an instruction
    //However, if the branch_mispredict signal is asserted, it means PC is being
    //changed on this cycle, and we should wait
    
    assign rd_en = next_rdy && !mispredict;
    assign PC_en = rd_en;
    
    reg vld_r = 0;
    always @(posedge clk) begin
        if (rst) vld_r <= 0;
        else vld_r <= rd_en;
    end
    
    assign vld = vld_r;
    
endmodule
