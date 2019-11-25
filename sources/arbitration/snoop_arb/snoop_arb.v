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

PESSIMISTIC MODE: The selected tag and all snooper->packetfilt_core signals are 
delayed by one cycle. This is to make it easier for Vivado to replicate logic 
in case fanout is too high.

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
    parameter DELAY_CONF = (N>16)? 1 : 0,
    parameter PESS = (N>16) //Enables pessimistic mode
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
    output wire [N-1:0] rdy_for_sn_ack //Yeah, I'm ready for a snack
    
);

`genif (N > 1) begin
    //Internal signals
    wire [TAG_SZ-1:0] selection_next;
    reg [TAG_SZ-1:0] selection_i = 0;
    wire [TAG_SZ-1:0] selection;
    
    wire [SN_ADDR_WIDTH-1:0] sn_addr_i;
    wire [DATA_WIDTH-1:0] sn_wr_data_i;
    wire [N-1:0] sn_wr_en_i;
    wire [INC_WIDTH-1:0] sn_byte_inc_i;
    wire [N-1:0] sn_done_i;
    wire [N-1:0] rdy_for_sn_ack_i;
    
    //Use tag tree to manage handshaking signals
    //This computes the rdy output, as well as the internal rdy_for_sn_ack_i
    //and selection signals. These internal signals are delayed in pessimistic 
    //mode.
    tag_tree # (
        .N(N),
        .TAG_SZ(TAG_SZ),
        .DELAY_CONF(DELAY_CONF) 
    ) the_tag_tree (
        .clk(clk),
        .rst(rst),
        
        .tag(selection_next),
        .rdy(rdy),
        .ack(ack),
        
        .rdy_in(rdy_for_sn),
        .ack_out(rdy_for_sn_ack_i)
    );
    
    //selection_i is registered when a handshake completes
    always @(posedge clk) begin
        if (rst) begin
            selection_i <= 0;
        end else begin
            if (rdy && ack) 
                selection_i <= selection_next;
        end
    end
    
    //Assign the rest of the internal signals
    assign sn_addr_i = addr;
    assign sn_wr_data_i = wr_data;
    assign sn_byte_inc_i = byte_inc;
    
    genvar i;
    for (i = 0; i < N; i = i + 1) begin : gate_hot
        assign sn_wr_en_i[i] = wr_en && (selection == i);
        assign sn_done_i[i] = done && (selection == i);
    end
    
    
    //In pessimistic mode, all internal signals are delayed. In non-pessimistic 
    //mode, they are directly assigned to the corresponding output
    
    if (PESS) begin : pessimistc_delays
        reg [TAG_SZ-1:0] selection_r = 0;
        
        reg [SN_ADDR_WIDTH-1:0] sn_addr_r = 0;
        reg [DATA_WIDTH-1:0] sn_wr_data_r = 0;
        reg [N-1:0] sn_wr_en_r = 0;
        reg [INC_WIDTH-1:0] sn_byte_inc_r = 0;
        reg [N-1:0] sn_done_r = 0;
        reg [N-1:0] rdy_for_sn_ack_r = 0;
        always @(posedge clk) begin
            sn_addr_r <= sn_addr_i;
            sn_wr_data_r <= sn_wr_data_i;
            sn_wr_en_r <= sn_wr_en_i;
            sn_byte_inc_r <= sn_byte_inc_i;
            sn_done_r <= sn_done_i;
            rdy_for_sn_ack_r <= rdy_for_sn_ack_i;
            selection_r <= selection_i;
        end
        assign sn_addr = sn_addr_r;
        assign sn_wr_data = sn_wr_data_r;
        assign sn_wr_en = sn_wr_en_r;
        assign sn_byte_inc = sn_byte_inc_r;
        assign sn_done = sn_done_r;
        assign rdy_for_sn_ack = rdy_for_sn_ack_r;
        assign selection = selection_r;
    end else begin : direct_assignment
        assign sn_addr = sn_addr_i;
        assign sn_wr_data = sn_wr_data_i;
        assign sn_wr_en = sn_wr_en_i;
        assign sn_byte_inc = sn_byte_inc_i;
        assign sn_done = sn_done_i;
        assign rdy_for_sn_ack = rdy_for_sn_ack_i;
        assign selection = selection_i;
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
