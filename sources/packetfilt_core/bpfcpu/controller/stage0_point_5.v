`timescale 1ns / 1ps

/*
stage0_point_5.v

If needed, this stage can be used to ease timing by breaking up the 
combinational path from code memory output to datapath control signals.

*/

module stage0_point_5 (
    input wire clk,
    input wire rst,
    
    input wire [63:0] instr_in,
    output wire [63:0] instr_out,
    
    input wire branch_mispredict,
    input wire prev_vld,
    output wire rdy,
    input wire next_rdy,
    output wire vld
);

    //See buffered_handshaking.txt for an explanation of this method
    reg [31:0] instr_r = 0;
    reg instr_r_vld = 0;
    
    reg [31:0] instr_b = 0; //buffered value for buffered handshake
    reg instr_b_vld = 0;

    wire shift_in;
    assign shift_in = prev_vld && rdy;

    wire shift_out;
    assign shift_out = next_rdy && vld;
    
    wire rst_i;
    assign rst_i = rst || branch_mispredict;
    
    //instr_r
    wire instr_r_en;
    assign instr_r_en = shift_in;
    always @(posedge clk) begin
        if (rst_i) begin
            instr_r <= 0;
        end else begin
            if (instr_r_en) begin
                instr_r <= (instr_b_vld) ? instr_b : instr_in;
            end
        end
    end
    
    //instr_r_vld
    always @(posedge clk) begin
        if (rst_i) begin
            instr_r_vld <= 0;
        end else begin
            if (instr_r_en) instr_r_vld <= 1;
            else if (shift_out) instr_r_vld <= 0;
        end
    end
    
    //instr_b
    wire instr_b_en;
    assign instr_b_en = shift_in && instr_vld && !shift_out;
    always @(posedge clk) begin
        if (rst_i) begin
            instr_r <= 0;
        end else begin
            if (instr_b_en) begin
                instr_b <= instr_in;
            end
        end
    end
    
    //instr_b_vld
    always @(posedge clk) begin
        if (rst_i) begin
            instr_b_vld <= 0;
        end else begin
            if (instr_b_en) instr_b_vld <= 1;
            else if (shift_out) instr_b_vld <= 0;
        end
    end
    
    //vld
    assign vld = instr_r_vld;
    assign instr_out = instr_r;
    
    //rdy
    assign rdy = !instr_b_vld;
endmodule
