`timescale 1ns / 1ps

/*

axistream_snooper.v

This is basically an AXI to BRAM bridge, but with the extra byte_inc logic

*/

`define genif generate if
`define endgen end endgenerate

`ifdef ICARUS_VERILOG
`define localparam parameter
`else /*For Vivado*/
`define localparam localparam
`endif

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
    input wire rdy_for_sn,
    output wire rdy_for_sn_ack, //Yeah, I'm ready for a snack
    
    output wire packet_dropped_inc //At any clock edge, a 1 means increment number of dropped packets
);
    /************************************/
    /**Forward-declare internal signals**/
    /************************************/
    
    //AXI stream snoop interface
    wire [SN_FWD_DATA_WIDTH-1:0] sn_TDATA_i;
    wire [KEEP_WIDTH-1:0] sn_TKEEP_i;
    wire sn_TREADY_i;
    wire sn_TVALID_i;
    wire sn_TLAST_i;
    
    //Interface to parallel_cores
    wire [SN_FWD_DATA_WIDTH-1:0] sn_wr_data_i;
    wire sn_wr_en_i;
    wire [INC_WIDTH-1:0] sn_byte_inc_i;
    wire sn_done_i;
    wire rdy_for_sn_i;
    wire rdy_for_sn_ack_i; //Yeah, I'm ready for a snack
    
    
    //State machine signals
    `localparam NOT_STARTED = 2'b00;
    `localparam WAITING = 2'b01;
    `localparam STARTED = 2'b11;
    reg [1:0] state = NOT_STARTED;
    wire valid_i;
    wire done_i;
    reg [SN_FWD_ADDR_WIDTH-1:0] addr_i = 0;
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/

    //AXI stream snoop interface
`genif (PESS) begin
    reg [SN_FWD_DATA_WIDTH-1:0] sn_TDATA_r = 0;
    reg [KEEP_WIDTH-1:0] sn_TKEEP_r = 0;
    reg sn_TREADY_r = 0;
    reg sn_TVALID_r = 0;
    reg sn_TLAST_r = 0;
    
    always @(posedge clk) begin
        if (rst) begin
            sn_TDATA_r <= 0;
            sn_TKEEP_r <= 0;
            sn_TREADY_r <= 0;
            sn_TVALID_r <= 0;
            sn_TLAST_r <= 0;
        end else begin
            sn_TDATA_r <= sn_TDATA;
            sn_TKEEP_r <= sn_TKEEP;
            sn_TREADY_r <= sn_TREADY;
            sn_TVALID_r <= sn_TVALID;
            sn_TLAST_r <= sn_TLAST;
        end
    end

    assign sn_TDATA_i = sn_TDATA_r;
    assign sn_TKEEP_i = sn_TKEEP_r;
    assign sn_TREADY_i = sn_TREADY_r;
    assign sn_TVALID_i = sn_TVALID_r;
    assign sn_TLAST_i = sn_TLAST_r;
    
end else begin
    assign sn_TDATA_i = sn_TDATA;
    assign sn_TKEEP_i = sn_TKEEP;
    assign sn_TREADY_i = sn_TREADY;
    assign sn_TVALID_i = sn_TVALID;
    assign sn_TLAST_i = sn_TLAST;
`endgen

    
    //Interface to parallel_cores
    assign rdy_for_sn_i = rdy_for_sn;    
    
    
    /****************/
    /**Do the logic**/
    /****************/
    
    //State machine logic. Please see READNE.txt for more details along
    //with a nice diagram
    
    //next-state logic
    always @(posedge clk) begin
        if (rst) begin
            state <= NOT_STARTED;
        end else begin
            case (state)
                NOT_STARTED:
                    //Normally we go to WAITING as soon as ready goes high, but
                    //we also include a special case for when ready and last are
                    //high at on the same cycle
                    state <= rdy_for_sn_i ? (sn_TLAST_i ? STARTED : WAITING) : NOT_STARTED;
                WAITING:
                    //TODO: should I keep assuming ready never goes low once it 
                    //goes high? The rest of the system is designed that way
                    state <= (sn_TVALID_i && sn_TREADY_i && sn_TLAST_i) ? STARTED : WAITING;
                STARTED:
                    state <= ({sn_TLAST_i, rdy_for_sn_i} == 2'b10) ? NOT_STARTED : STARTED;
            endcase
        end
    end
    
    //state machine outputs. Note this is a Mealy machine
    assign rdy_for_sn_ack_i = (state == NOT_STARTED) || (state == STARTED && sn_TLAST_i);
    assign valid_i = (state == STARTED) && sn_TVALID_i && sn_TREADY_i;
    assign done_i = (state == STARTED) && sn_TLAST_i;
    
    //Actual AXI-to-BRAM conversion
    assign sn_wr_data_i = sn_TDATA_i;
    assign sn_wr_en_i = valid_i;
    always @(posedge clk) begin
        if (rst) begin
            addr_i <= 0;
        end else begin
            addr_i <= (done_i) ? 0 : (addr_i + valid_i);
        end
    end
    //TODO: do actual TKEEP logic
    assign sn_byte_inc_i = SN_FWD_DATA_WIDTH/8;
    assign sn_done_i = done_i;
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    //Interface to parallel_cores
    assign sn_addr = addr_i;
    assign sn_wr_data = sn_wr_data_i;
    assign sn_wr_en = sn_wr_en_i;
    assign sn_byte_inc = sn_byte_inc_i;
    assign sn_done = sn_done_i;
    assign rdy_for_sn_ack = rdy_for_sn_ack_i; //Yeah, I'm ready for a snack
    
    assign packet_dropped_inc = (state == WAITING) && (sn_TVALID_i && sn_TREADY_i && sn_TLAST_i);

endmodule

`undef localparam
