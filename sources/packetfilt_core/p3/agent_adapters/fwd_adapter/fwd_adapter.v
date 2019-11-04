`timescale 1ns / 1ps

/* 

This can be the second-trickiest adapter. Unlike snooper which essentially just 
posts writes and forgets about them, the forwarder has a sort of dialogue with 
the P3 controller and the packet buffer.

The biggest complication is the memory latency, and how that can also make the 
ready and done signal handshaking messy.

For now, I'm letting the whole adapter be combinational. This may casue timing 
problems later though, so I've written this file in the same format as my other 
modules. This is because it will be easier to add pessimistic registers if I do 
it like this.


 */

module fwd_adapter # (
    parameter FWD_ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64,
    //These control pessimistic registers in the p_ng buffers
    parameter BUF_IN = 0,
    parameter BUF_OUT = 0,
    parameter PESS = 0 //If 1, our output will be buffered
)(
    input wire clk,
    input wire rst,
    
    //Interface to forwarder
    input wire [FWD_ADDR_WIDTH-1:0] fwd_addr,
    input wire fwd_rd_en,
    input wire fwd_done,
    input wire fwd_done_vld,
    input wire rdy_for_fwd_ack,
    
    output wire fwd_done_ack,
    output wire rdy_for_fwd,
    output wire rdy_for_fwd_vld,
    output wire [DATA_WIDTH-1:0] fwd_rd_data,
    output wire [31:0] fwd_bytes,
    
    //Interface to P3 system
    output wire [FWD_ADDR_WIDTH+1-1:0] addr,
    output wire rd_en,
    output wire done,
    output wire done_vld,
    output wire rdy_ack,
    
    input wire done_ack,
    input wire rdy,
    input wire rdy_vld,
    input wire [DATA_WIDTH-1:0] rd_data,
    input wire [31:0] bytes
);    
    /************************************/
    /**Forward-declare internal signals**/
    /************************************/
    
    //Interface to forwarder
    wire [FWD_ADDR_WIDTH-1:0] fwd_addr_i;
    wire fwd_rd_en_i;
    wire fwd_done_i;
    wire fwd_done_vld_i;
    wire rdy_for_fwd_ack_i;
    
    wire fwd_done_ack_i;
    wire rdy_for_fwd_i;
    wire rdy_for_fwd_vld_i;
    wire [DATA_WIDTH-1:0] fwd_rd_data_i;
    wire [31:0] fwd_bytes_i;
    
    //Interface to P3 system
    wire [FWD_ADDR_WIDTH+1-1:0] addr_i;
    wire rd_en_i;
    wire done_i;
    wire done_vld_i;
    wire rdy_ack_i;
    
    wire done_ack_i;
    wire rdy_i;
    wire rdy_vld_i;
    wire [DATA_WIDTH-1:0] rd_data_i;
    wire [31:0] bytes_i;
    
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    //Interface to forwarder
    assign fwd_addr_i        = fwd_addr;
    assign fwd_rd_en_i       = fwd_rd_en;
    assign fwd_done_i        = fwd_done;
    assign fwd_done_vld_i    = fwd_done_vld;
    assign rdy_for_fwd_ack_i = rdy_for_fwd_ack;
    
    //Interface to P3 system
    assign done_ack_i        = done_ack;
    assign rdy_i             = rdy;
    assign rdy_vld_i         = rdy_vld;
    assign rd_data_i         = rd_data;
    assign bytes_i           = bytes;
    
    /****************/
    /**Do the logic**/
    /****************/
    
    assign addr_i            = {fwd_addr_i, 1'b0};
    assign rd_en_i           = fwd_rd_en_i;
    assign done_i            = fwd_done_i;
    assign done_vld_i        = fwd_done_vld_i;
    assign rdy_ack_i         = rdy_for_fwd_ack_i;
    
    assign fwd_done_ack_i    = done_ack_i;
    assign rdy_for_fwd_i     = rdy_i;
    assign rdy_for_fwd_vld_i = rdy_vld_i;
    assign fwd_rd_data_i     = rd_data_i;
    assign fwd_bytes_i       = bytes_i;
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    //Interface to forwarder    
    assign fwd_done_ack      = fwd_done_ack_i;
    assign rdy_for_fwd       = rdy_for_fwd_i;
    assign rdy_for_fwd_vld   = rdy_for_fwd_vld_i;
    assign fwd_rd_data       = fwd_rd_data_i;
    assign fwd_bytes         = fwd_bytes_i;
    
    //Interface to P3 system
    assign addr              = addr_i;
    assign rd_en             = rd_en_i;
    assign done              = done_i;
    assign done_vld          = done_vld_i;
    assign rdy_ack           = rdy_ack_i;

endmodule
