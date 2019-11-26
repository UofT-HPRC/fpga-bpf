`timescale 1ns / 1ps

/*

ud_counter.v

A simple counter with up and down inputs

*/

module ud_counter # (
    parameter WIDTH = 8,
    parameter INIT_CNT = 0
) (
    input wire clk,
    input wire rst,
    
    input wire up,
    input wire down,
    
    output wire [WIDTH-1-0] count
);

    reg [WIDTH-1:0] count_i = INIT_CNT;
    
    always @(posedge clk) begin
        if (rst) begin
            count_i <= INIT_CNT;
        end else begin
            if (up && !down) begin
                count_i <= count_i + 1;
            end else if (down && !up) begin
                count_i <= count_i - 1;
            end
        end
    end

endmodule
