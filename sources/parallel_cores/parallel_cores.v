`timescale 1ns / 1ps

/*

parallel_cores.v

If everything goes to plan, this module should have the exact same interface as
a single packetfilter_core.

*/

`ifdef FROM_PARALLEL_CORES
`include "packetfilter_core/packetfilter_core.v"
`include "arbitration/snoop_arb/snoop_arb.v"
`endif

`define CLOG2(x) (\
   (((x) <= 2) ? 1 : \
   (((x) <= 4) ? 2 : \
   (((x) <= 8) ? 3 : \
   (((x) <= 16) ? 4 : \
   (((x) <= 32) ? 5 : \
   (((x) <= 64) ? 6 : \
   (((x) <= 128) ? 7 : \
   (((x) <= 256) ? 8 : \
   (((x) <= 512) ? 9 : \
   (((x) <= 1024) ? 10 : \
   (((x) <= 2048) ? 11 : \
   (((x) <= 4096) ? 12 : \
   (((x) <= 8192) ? 13 : \
   (((x) <= 16384) ? 14 : \
   (((x) <= 32768) ? 15 : \
   (((x) <= 65536) ? 16 : \
   -1)))))))))))))))))


module parallel_cores # (
    parameter N = 4,
    parameter PACKET_MEM_BYTES = 2048,
    parameter INST_MEM_DEPTH = 512,
    parameter SN_FWD_DATA_WIDTH = 64,
    parameter BUF_IN = 0,
    parameter BUF_OUT = 0,
    parameter PESS = 0,
    
    
    //Derived parameters. Probably shouldn't set these manually, except maybe
    //DELAY_CONF
    
    //DELAY_CONF:
    //0 = all combinational
    //1 = delay stage on every second level
    //2 = delay stage on all levels
    parameter DELAY_CONF = (N>16)? 1 : 0,
    
    parameter TAG_SZ = `CLOG2(N),
    parameter CODE_ADDR_WIDTH = `CLOG2(INST_MEM_DEPTH),
    parameter CODE_DATA_WIDTH = 64,
    parameter BYTE_ADDR_WIDTH = `CLOG2(PACKET_MEM_BYTES),
    parameter SN_FWD_ADDR_WIDTH = BYTE_ADDR_WIDTH - `CLOG2(SN_FWD_DATA_WIDTH/8),
    parameter INC_WIDTH = `CLOG2(SN_FWD_DATA_WIDTH/8)+1,
    parameter PLEN_WIDTH = 32
) (
    input wire clk,
    input wire rst,
    
    
    //Interface to snooper
    input wire [SN_FWD_ADDR_WIDTH-1:0] sn_addr,
    input wire [SN_FWD_DATA_WIDTH-1:0] sn_wr_data,
    input wire sn_wr_en,
    input wire [INC_WIDTH-1:0] sn_byte_inc,
    input wire sn_done,
    output wire sn_done_ack,
    output wire rdy_for_sn,
    input wire rdy_for_sn_ack, //Yeah, I'm ready for a snack
    
    //Interface to forwarder
    input wire [SN_FWD_ADDR_WIDTH-1:0] fwd_addr,
    input wire fwd_rd_en,
    output wire [SN_FWD_DATA_WIDTH-1:0] fwd_rd_data,
    output wire fwd_rd_data_vld,
    output wire [PLEN_WIDTH-1:0] fwd_byte_len,
    input wire fwd_done,
    output wire fwd_done_ack,
    output wire rdy_for_fwd,
    input wire rdy_for_fwd_ack,
    
    //Interface for new code input
    input wire [CODE_ADDR_WIDTH-1:0] inst_wr_addr,
    input wire [CODE_DATA_WIDTH-1:0] inst_wr_data,
    input wire inst_wr_en
    
);
    /*************************************/
    /***snoop_arb <=> packetfiler_cores***/
    /*************************************/
    
    //Interface to packetfilter_cores
    wire [N-1:0] rdy_for_sn_i;
    
    wire [SN_FWD_ADDR_WIDTH-1:0] sn_addr_i;
    wire [SN_FWD_DATA_WIDTH-1:0] sn_wr_data_i;
    wire [N-1:0] sn_wr_en_i;
    wire [INC_WIDTH-1:0] sn_byte_inc_i;
    wire [N-1:0] sn_done_i;
    wire [N-1:0] rdy_for_sn_ack_i; //Yeah, I'm ready for a snack

    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin
        packetfilter_core # (
            .PACKET_MEM_BYTES(PACKET_MEM_BYTES),
            .INST_MEM_DEPTH(INST_MEM_DEPTH),
            .SN_FWD_DATA_WIDTH(SN_FWD_DATA_WIDTH),
            .BUF_IN(BUF_IN),
            .BUF_OUT(BUF_OUT),
            .PESS(PESS)
        ) filt (
            .clk(clk),
            .rst(rst),


            //Interface to snooper
            .sn_addr(sn_addr_i),
            .sn_wr_data(sn_wr_data_i),
            .sn_wr_en(sn_wr_en_i[i]),
            .sn_byte_inc(sn_byte_inc_i),
            .sn_done(sn_done_i[i]),
            //.sn_done_ack(????),
            .rdy_for_sn(rdy_for_sn_i[i]),
            .rdy_for_sn_ack(rdy_for_sn_ack_i[i]), //Yeah, I'm ready for a snack

            //TODO forwarder arbiter stuff
            //Interface to forwarder
            //.fwd_addr(fwd_addr),
            //.fwd_rd_en(fwd_rd_en),
            //.fwd_rd_data(fwd_rd_data),
            //.fwd_rd_data_vld(fwd_rd_data_vld),
            //.fwd_byte_len(fwd_byte_len),
            //.fwd_done(fwd_done),
            //.fwd_done_ack(fwd_done_ack),
            //.rdy_for_fwd(rdy_for_fwd),
            //.rdy_for_fwd_ack(rdy_for_fwd_ack),

            //Interface for new code input
            .inst_wr_addr(inst_wr_addr),
            .inst_wr_data(inst_wr_data),
            .inst_wr_en(inst_wr_en)
        );
    end endgenerate

    snoop_arb # (
        .SN_ADDR_WIDTH(SN_FWD_ADDR_WIDTH),
        .DATA_WIDTH(SN_FWD_DATA_WIDTH),
        .INC_WIDTH(INC_WIDTH),
        .N(N),
        .TAG_SZ(TAG_SZ),
        .DELAY_CONF(DELAY_CONF),
        .PESS(PESS)
    ) snooper_arbiter (
        .clk(clk),
        .rst(rst),

        //Interface to snooper
        .addr(sn_addr),
        .wr_data(sn_wr_data),
        .wr_en(sn_wr_en),
        .byte_inc(sn_byte_inc),
        .done(sn_done),
        .ack(rdy_for_sn_ack),

        .done_ack(sn_done_ack), 
        .rdy(rdy_for_sn),

        //Interface to packetfilter_cores
        //.sn_done_ack(sn_done_ack),
        .rdy_for_sn(rdy_for_sn_i),

        .sn_addr(sn_addr_i),
        .sn_wr_data(sn_wr_data_i),
        .sn_wr_en(sn_wr_en_i),
        .sn_byte_inc(sn_byte_inc_i),
        .sn_done(sn_done_i),
        .rdy_for_sn_ack(rdy_for_sn_ack_i) //Yeah, I'm ready for a snack   
    );

    //TODO: forwarder arbiter.

endmodule

`undef CLOG2
