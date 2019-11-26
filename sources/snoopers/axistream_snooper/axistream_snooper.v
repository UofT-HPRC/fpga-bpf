`timescale 1ns / 1ps

/*

axistream_snooper.v

At least for today I'll draft the module definition and the easy logic (if 
there is any)

How should this work?

Well, let's not go crazy!

A simple state machine should be fine. Some states I will need:

    - need_to_wait (we're ready, but only became ready haflway through a packet)
    - normal (but note that we can abort)

That might be it actually. In normal mode, we simply keep incrementing our 
output address and forward the data. Of course, we whould have an option for
pessimistic timing.

But I'm done for today. 

*/

module axistream_snooper # (
    parameter SN_FWD_DATA_WIDTH = 64,
    parameter SN_FWD_ADDR_WIDTH = 9,
    parameter INC_WIDTH = 8,
    parameter PESS = 0,
    
    //Derived parameters. Don't set these
    parameter KEEP_WIDTH = SN_FWD_DATA_WIDTH/8
) (
    input wire clk,
    input wire rst,
    
    //AXI stream snoop interface
    //TODO: have parameter to enable/disable backpressure
    //TODO: enable/disable TKEEP? 
    input wire [SN_FWD_DATA_WIDTH-1:0] sn_TDATA,
    input wire [KEEP_WIDTH-1:0] sn_TKEEP,
    input wire sn_TREADY,
    input wire sn_TVALID,
    input wire sn_TLAST,
    
    //Interface to parallel_cores
    output wire [SN_FWD_ADDR_WIDTH-1:0] sn_addr,
    output wire [SN_FWD_DATA_WIDTH-1:0] sn_wr_data,
    output wire sn_wr_en,
    output wire [INC_WIDTH-1:0] sn_byte_inc,
    output wire sn_done,
    input wire sn_done_ack,
    input wire rdy_for_sn,
    output wire rdy_for_sn_ack //Yeah, I'm ready for a snack
);
    /************************************/
    /**Forward-declare internal signals**/
    /************************************/
    
    
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    
    
    
    /************************************/
    /**Helpful names for neatening code**/
    /************************************/
    
    
    
    /****************/
    /**Do the logic**/
    /****************/
    
    
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/



endmodule
