`timescale 1ns / 1ps

/* 

This is the simplest adapter, I guess

 */

module sn_adapter # (
    parameter SN_ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64,
    //These control pessimistic registers in the p_ng buffers
    parameter BUF_IN = 0,
    parameter BUF_OUT = 0,
    parameter PESS = 0 //If 1, our output will be buffered
)(
    input wire clk,
    input wire rst,
    
    //Interface to snooper
    input wire [SN_ADDR_WIDTH-1:0] sn_addr,
    input wire [DATA_WIDTH-1:0] sn_wr_data,
    input wire sn_wr_en,
    input wire [7:0] sn_byte_inc,
    input wire sn_done,
    input wire sn_done_vld,
    input wire rdy_for_sn_ack,
    
    output wire sn_done_ack,
    output wire rdy_for_sn,
    output wire rdy_for_sn_vld,
    
    //Interface to P3 system
    output wire [SN_ADDR_WIDTH+1-1:0] addr,
    output wire wr_en,
    output wire [DATA_WIDTH-1:0] wr_data,
    output wire [7:0] byte_inc,
    output wire done,
    output wire done_vld,
    output wire rdy_ack,
    
    input wire done_ack,
    input wire rdy,
    input wire rdy_vld
);    
    /************************************/
    /**Forwawr-declare internal signals**/
    /************************************/
    
    //Interface to snooper
    wire [SN_ADDR_WIDTH-1:0] sn_addr_i;
    wire [DATA_WIDTH-1:0] sn_wr_data_i;
    wire sn_wr_en_i;
    wire [7:0] sn_byte_inc_i;
    wire sn_done_i;
    wire sn_done_vld_i;
    wire rdy_for_sn_ack_i;
    
    wire sn_done_ack_i;
    wire rdy_for_sn_i;
    wire rdy_for_sn_vld_i;
    
    //Interface to P3 system
    wire [SN_ADDR_WIDTH+1-1:0] addr_i;
    wire wr_en_i;
    wire [DATA_WIDTH-1:0] wr_data_i;
    wire [7:0] byte_inc_i;
    wire done_i;
    wire done_vld_i;
    wire rdy_ack_i;
    
    wire done_ack_i;
    wire rdy_i;
    wire rdy_vld_i;
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    assign sn_addr_i         = sn_addr;
    assign sn_wr_data_i      = sn_wr_data;
    assign sn_wr_en_i        = sn_wr_en;
    assign sn_byte_inc_i     = sn_byte_inc;
    assign sn_done_i         = sn_done;
    assign sn_done_vld_i     = sn_done_vld;
    assign rdy_for_sn_ack_i  = rdy_for_sn_ack;
    
    assign done_ack_i  = done_ack;
    assign rdy_i       = rdy;
    assign rdy_vld_i   = rdy_vld;
    
    /****************/
    /**Do the logic**/
    /****************/
    
    assign addr_i       = {sn_addr_i, 1'b0};
    assign wr_en_i      = sn_wr_en_i;
    assign wr_data_i    = sn_wr_data_i;
    assign byte_inc_i   = sn_byte_inc_i;
    assign done_i       = sn_done_i;
    assign done_vld_i   = sn_done_vld_i;
    assign rdy_ack_i    = rdy_for_sn_ack_i;

    assign sn_done_ack_i    = done_ack_i;
    assign rdy_for_sn_i     = rdy_i;     
    assign rdy_for_sn_vld_i = rdy_vld_i;
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    assign addr         = addr_i;
    assign wr_en        = wr_en_i;
    assign wr_data      = wr_data_i;
    assign byte_inc     = byte_inc_i;
    assign done         = done_i;
    assign done_vld     = done_vld_i;
    assign rdy_ack      = rdy_ack_i;

    assign sn_done_ack = sn_done_ack_i;
    assign rdy_for_sn = rdy_for_sn_i;
    assign rdy_for_sn_vld = rdy_for_sn_vld_i;
    
endmodule
