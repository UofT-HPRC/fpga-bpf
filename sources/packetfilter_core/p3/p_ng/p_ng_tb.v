`timescale 1ns / 1ps
`include "p_ng.v"

/*
Testbench associated with p_ng.v

*/

`define ADDR_WIDTH 10
`define SN_FWD_WIDTH 64
`define INC_WIDTH 8
`define PLEN_WIDTH 32

module p_ng_tb;

    reg clk;
    reg rst; //Note: does not actually change the stored memory
    reg rd_en; //@0
    reg wr_en; //@0
    reg [`ADDR_WIDTH-1:0] addr; //@0
    reg [`SN_FWD_WIDTH-1:0] idata; //@0
    reg [`INC_WIDTH-1:0] byte_inc; //@0
    
    wire [`SN_FWD_WIDTH-1:0] odata_NOBUF; //@1
    wire odata_vld_NOBUF; //@1
    
    wire [`SN_FWD_WIDTH-1:0] odata_INBUF; //@2
    wire odata_vld_INBUF; //@2
    
    wire [`SN_FWD_WIDTH-1:0] odata_OUTBUF; //@2
    wire odata_vld_OUTBUF; //@2
    
    wire [`SN_FWD_WIDTH-1:0] odata_BOTHBUF; //@3
    wire odata_vld_BOTHBUF; //@3
    
    wire [`PLEN_WIDTH-1:0] byte_length_NOBUF; //@1
    wire [`PLEN_WIDTH-1:0] byte_length_INBUF; //@2
    wire [`PLEN_WIDTH-1:0] byte_length_OUTBUF; //@2
    wire [`PLEN_WIDTH-1:0] byte_length_BOTHBUF; //@3
    
    integer fd, dummy;
    
    initial begin
        $dumpfile("p_ng.vcd");
        $dumpvars;
        $dumplimit(1024000);
        clk <= 0;
        rst <= 0;
        rd_en <= 0;
        wr_en <= 0;
        addr <= 0;
        idata <= 0;
        byte_inc <= 0;
        
        fd = $fopen("p_ng_drivers.mem", "r");
        while($fgetc(fd) != "\n") begin end //Skip first line of comments
    end
    
    always #5 clk <= ~clk;
    
    always @(posedge clk) begin
        if ($feof(fd)) begin
            $display("Reached end of drivers file");
            #20
            $finish;
        end
        #0.01
        dummy = $fscanf(fd, "%b%b%h%h%d%b", rd_en, wr_en, addr, idata, byte_inc, rst);
    end

    p_ng # (
        .ADDR_WIDTH(`ADDR_WIDTH),
        .SN_FWD_WIDTH(`SN_FWD_WIDTH),
        .INC_WIDTH(`INC_WIDTH),
        .PLEN_WIDTH(`PLEN_WIDTH),
        //parameters controlling addition of pessmistic registers
        .BUF_IN(0),
        .BUF_OUT(0)
    ) DUT_NOBUF (
        .clk(clk),
        .rst(rst), //Note: does not actually change the stored memory
        .rd_en(rd_en), //@0
        .wr_en(wr_en), //@0
        .addr(addr), //@0
        .idata(idata), //@0
        .byte_inc(byte_inc), //@0
        .odata(odata_NOBUF), //@1
        .odata_vld(odata_vld_NOBUF), //@1
        .byte_length(byte_length_NOBUF) //@1
    );
    
    p_ng # (
        .ADDR_WIDTH(10),
        .SN_FWD_WIDTH(64),
        //parameters controlling addition of pessmistic registers
        .BUF_IN(1),
        .BUF_OUT(0)
    ) DUT_INBUF (
        .clk(clk),
        .rst(rst), //Note: does not actually change the stored memory
        .rd_en(rd_en), //@0
        .wr_en(wr_en), //@0
        .addr(addr), //@0
        .idata(idata), //@0
        .byte_inc(byte_inc), //@0
        .odata(odata_INBUF), //@2
        .odata_vld(odata_vld_INBUF), //@2
        .byte_length(byte_length_INBUF) //@2
    );

    p_ng # (
        .ADDR_WIDTH(10),
        .SN_FWD_WIDTH(64),
        //parameters controlling addition of pessmistic registers
        .BUF_IN(0),
        .BUF_OUT(1)
    ) DUT_OUTBUF (
        .clk(clk),
        .rst(rst), //Note: does not actually change the stored memory
        .rd_en(rd_en), //@0
        .wr_en(wr_en), //@0
        .addr(addr), //@0
        .idata(idata), //@0
        .byte_inc(byte_inc), //@0
        .odata(odata_OUTBUF), //@2
        .odata_vld(odata_vld_OUTBUF), //@2
        .byte_length(byte_length_OUTBUF) //@2
    );


    p_ng # (
        .ADDR_WIDTH(10),
        .SN_FWD_WIDTH(64),
        //parameters controlling addition of pessmistic registers
        .BUF_IN(1),
        .BUF_OUT(1)
    ) DUT_BOTHBUF (
        .clk(clk),
        .rst(rst), //Note: does not actually change the stored memory
        .rd_en(rd_en), //@0
        .wr_en(wr_en), //@0
        .addr(addr), //@0
        .idata(idata), //@0
        .byte_inc(byte_inc), //@0
        .odata(odata_BOTHBUF), //@3
        .odata_vld(odata_vld_BOTHBUF), //@3
        .byte_length(byte_length_BOTHBUF) //@3
    );
endmodule
