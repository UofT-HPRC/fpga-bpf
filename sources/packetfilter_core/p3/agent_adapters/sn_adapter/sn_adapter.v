`timescale 1ns / 1ps

/* 

This is the simplest adapter, I guess

 */

module sn_adapter # (
    parameter SN_ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64,
    parameter INC_WIDTH = 8
)(
    input wire clk,
    input wire rst,
    
    //Interface to snooper
    input wire [SN_ADDR_WIDTH-1:0] sn_addr,
    input wire [DATA_WIDTH-1:0] sn_wr_data,
    input wire sn_wr_en,
    input wire [INC_WIDTH-1:0] sn_byte_inc,
    input wire sn_done,
    input wire rdy_for_sn_ack,
    
    output wire sn_done_ack,
    output wire rdy_for_sn,
    
    //Interface to P3 system
    output wire [SN_ADDR_WIDTH+1-1:0] addr,
    output wire wr_en,
    output wire [DATA_WIDTH-1:0] wr_data,
    output wire [INC_WIDTH-1:0] byte_inc,
    output wire done,
    output wire rdy_ack,
    
    input wire done_ack,
    input wire rdy
);    
    /************************************/
    /**Forwawr-declare internal signals**/
    /************************************/
    
    //Interface to snooper
    wire [SN_ADDR_WIDTH-1:0] sn_addr_i;
    wire [DATA_WIDTH-1:0] sn_wr_data_i;
    wire sn_wr_en_i;
    wire [INC_WIDTH-1:0] sn_byte_inc_i;
    wire sn_done_i;
    wire rdy_for_sn_ack_i;
    
    wire sn_done_ack_i;
    wire rdy_for_sn_i;
    
    //Interface to P3 system
    wire [SN_ADDR_WIDTH+1-1:0] addr_i;
    wire wr_en_i;
    wire [DATA_WIDTH-1:0] wr_data_i;
    wire [INC_WIDTH-1:0] byte_inc_i;
    wire done_i;
    wire rdy_ack_i;
    
    wire done_ack_i;
    wire rdy_i;
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    assign sn_addr_i         = sn_addr;
    assign sn_wr_data_i      = sn_wr_data;
    assign sn_wr_en_i        = sn_wr_en;
    assign sn_byte_inc_i     = sn_byte_inc;
    assign sn_done_i         = sn_done;
    assign rdy_for_sn_ack_i  = rdy_for_sn_ack;
    
    assign done_ack_i  = done_ack;
    assign rdy_i       = rdy;
    
    /****************/
    /**Do the logic**/
    /****************/
    
    assign addr_i       = {sn_addr_i, 1'b0};
    assign wr_en_i      = sn_wr_en_i;
    assign wr_data_i    = sn_wr_data_i;
    assign byte_inc_i   = sn_byte_inc_i;
    assign done_i       = sn_done_i;
    assign rdy_ack_i    = rdy_for_sn_ack_i;

    assign sn_done_ack_i    = done_ack_i;
    assign rdy_for_sn_i     = rdy_i;
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    assign addr         = addr_i;
    assign wr_en        = wr_en_i;
    assign wr_data      = wr_data_i;
    assign byte_inc     = byte_inc_i;
    assign done         = done_i;
    assign rdy_ack      = rdy_ack_i;

    assign sn_done_ack = sn_done_ack_i;
    assign rdy_for_sn = rdy_for_sn_i;
    
endmodule
