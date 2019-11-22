`timescale 1ns / 1ps

/*
snoop_arb.v

Originally, this tag-checking logic was meant to be in the tag_tree module, but 
then I decided it would be better to keep the tag tree as a separate entity 
with one specific purpose. With any luck, it should prevent the arbitration 
from devolving into the horrible spaghetti monster I had the last time...

One more thing: by having this extra indirection, I can be smart about doing 
the special case where N = 1.

TODO: Verify that idea to remove handshaking the done signal makes sense, and 
if so, remove it properly

*/

`ifdef FROM_SNOOP_ARB
`include "tag_tree/tag_tree.v"
`endif

`define genif generate if
`define endgen end endgenerate

module snoop_arb # (
    parameter SN_ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64,
    parameter INC_WIDTH = 8,
    parameter N = 4,
    parameter TAG_SZ = 5,
    //DELAY_CONF:
    //0 = all combinational
    //1 = delay stage on every second level
    //2 = delay stage on all levels
    parameter DELAY_CONF = 1
) (
    input wire clk,
    input wire rst,
    
    //Interface to snooper
    input wire [SN_ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] wr_data,
    input wire wr_en,
    input wire [INC_WIDTH-1:0] byte_inc,
    input wire done,
    input wire ack,
    
    output wire done_ack, //IDEA: no handshaking for done signal? Significantly cleans up logic
    output wire rdy,
    
    //Interface to packetfilter_cores
    //input wire [N-1:0] sn_done_ack, //IDEA: no handshaking for done signal? Significantly cleans up logic
    input wire [N-1:0] rdy_for_sn,
    
    //Only hot signals need to be gated, so we avoid the 2D array port problem 
    output wire [SN_ADDR_WIDTH-1:0] sn_addr,
    output wire [DATA_WIDTH-1:0] sn_wr_data,
    output wire [N-1:0] sn_wr_en,
    output wire [INC_WIDTH-1:0] sn_byte_inc,
    output wire [N-1:0] sn_done,
    output wire [N-1:0] rdy_for_sn_ack, //Yeah, I'm ready for a snack
    output wire [N-1-1:0] param_debug
    
);

`genif (N > 1) begin
    //Internal signals
    wire [TAG_SZ-1:0] selection;
    
    //Use tag tree to manage handshaking signals
    tag_tree # (
        .N(N),
        .TAG_SZ(TAG_SZ),
        .DELAY_CONF(DELAY_CONF) 
    ) the_tag_tree (
        .clk(clk),
        .rst(rst),
        
        .tag(selection),
        .rdy(rdy),
        .ack(ack),
        
        .rdy_in(rdy_for_sn),
        .ack_out(rdy_for_sn_ack),
        .param_debug(param_debug)
    );
    
    //Now assign the rest of the outputs, taking care to gate hot signals
    assign sn_addr = addr;
    assign sn_wr_data = wr_data;
    assign sn_byte_inc = byte_inc;
    
    genvar i;
    for (i = 0; i < N; i = i + 1) begin : gate_hot
        assign sn_wr_en[i] = wr_en && (selection == i);
        assign sn_done[i] = wr_en && (selection == i);
    end
    
    assign done_ack = 1; //IDEA: no handshaking for done signal? Significantly cleans up logic

end else begin
    //Special case: N = 1
    //The tag tree is smart enough to DTRT when N = 1, and this will cause the
    //selected tag to be a constant zero. In the gate_hot for loop, Vivado 
    //should be smart enough to optimize away the comparison on the tag.
    //However, it's not a good idea to bank on Vivado being smart, and this was
    //really easy to do:
    assign sn_addr = addr;
    assign sn_wr_data = wr_data;
    assign sn_byte_inc = byte_inc;
    assign sn_wr_en[0] = wr_en;
    assign sn_done[0] = done;
    assign rdy_for_sn_ack[0] = ack; 
    
    assign done_ack = 1; //IDEA: no handshaking for done signal? Significantly cleans up logic
`endgen

endmodule

`undef genif
`undef endgen
