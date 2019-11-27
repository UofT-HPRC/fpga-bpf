`timescale 1ns / 1ps

/*

fwd_arb.v

Wires up a tag tree and a mux tree. Uses the tricky tag_gen module to generate 
tags for each packetfilter_core.

*/

`ifdef FROM_FWD_ARB
`include "tag_gen/tag_gen.v"
`include "mux_tree/mux_tree.v"
`endif

module fwd_arb # (
    parameter X = 5
) (
    input wire clk,
    input wire rst,
    
    //Interface to forwarder
    input wire [SN_FWD_ADDR_WIDTH-1:0] fwd_addr,
    input wire fwd_rd_en,
    output wire [SN_FWD_DATA_WIDTH-1:0] fwd_rd_data,
    output wire fwd_rd_data_vld,
    output wire [PLEN_WIDTH-1:0] fwd_byte_len,
    input wire fwd_done,
    output wire rdy_for_fwd,
    input wire rdy_for_fwd_ack,
);

endmodule
