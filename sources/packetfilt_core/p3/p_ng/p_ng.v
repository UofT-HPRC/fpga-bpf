`timescale 1ns / 1ps

/*
p_ng.v
------
One of the ping/pang/pong buffers.

This core has several parameters, which will influence the schedule:
    BUF_IN: if true, inputs are buffered for a cycle
    BUF_OUT: if true, outputs are buffered for a cycle


CONVENTIONS
-----------
x_i means "internal x"
x_r meand "registered x"
Modules are structured as:
    forward declarations and localparams
    input buffering (if necessary)
    actual logic (which may have internal buffering)
    output buffering (if necessary
*/


//Quick module which Vivado should synthesize as a BRAM
//See the Xilinx Synthesis Technology report for details
module dp_bram # (
    parameter ADDR_WIDTH = 10,
    parameter PORT_WIDTH = 32
) (
    input wire clk,
    
    input wire en,                           //@0
    
    input wire [ADDR_WIDTH-1:0] addra,  //@0
    input wire [ADDR_WIDTH-1:0] addrb,  //@0

    input wire [PORT_WIDTH-1:0] dia,    //@0
    input wire [PORT_WIDTH-1:0] dib,    //@0
    input wire wr_en,                   //@0
    
    output reg [PORT_WIDTH-1:0] doa,    //@1
    output reg [PORT_WIDTH-1:0] dob     //@1
);
    reg [PORT_WIDTH-1:0] data [0:2**ADDR_WIDTH-1];

    always @(posedge clk) begin
        if (en) begin
            if (wr_en == 1'b1) begin
                data[addra] <= dia;
            end
            doa <= data[addra]; //Read-first mode
        end
    end

    always @(posedge clk) begin
        if (en) begin
            if (wr_en == 1'b1) begin
                data[addrb] <= dib;
            end
            dob <= data[addrb]; //Read-first mode
        end
    end
endmodule


//The actual module we're after is here
module p_ng # (
    parameter ADDR_WIDTH = 10,
    parameter SN_FWD_WIDTH = 64,
    //parameters controlling addition of pessmistic registers
    parameter BUF_IN = 0,
    parameter BUF_OUT = 0
) (
    input wire clk,
    input wire rst, //Note: does not actually change the stored memory
    input wire rd_en, //@0
    input wire wr_en, //@0
    input wire [ADDR_WIDTH-1:0] addr, //@0
    input wire [SN_FWD_WIDTH-1:0] idata, //@0
    input wire [8:0] byte_inc, //@0
    output wire [SN_FWD_WIDTH-1:0] odata, //@1 + BUF_IN + BUF_OUT
    output wire [32:0] byte_length //@1 + BUF_IN + BUF_OUT
);

    //Width of each port is half the total width
    localparam PORT_WIDTH = (SN_FWD_WIDTH>>1);


    //Real quick, let's get the length logic out of the way:
    reg [32:0] byte_length_i = 0;
    always @(posedge clk) begin
        if (!rst) begin
            if (wr_en) begin
                byte_length_i <= byte_length_i + byte_inc;
            end else begin
                byte_length_i <= byte_length_i;
            end
        end else begin
            byte_length_i <= 0;
        end
    end
    
    assign byte_length = byte_length_i;
    
    /************************************/
    /**Forward-declare internal signals**/
    /************************************/
    wire rd_en_i;
    wire wr_en_i; 
    wire [ADDR_WIDTH-1:0] addr_i; 
    wire [SN_FWD_WIDTH-1:0] idata_i;
    wire [SN_FWD_WIDTH-1:0] odata_i;
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    
    //Select whether the inputs are buffered or not
generate
    if (BUF_IN) begin
        reg rd_en_r = 0;                     
        reg wr_en_r = 0;                     
        reg [ADDR_WIDTH-1:0] addr_r = 0;
        reg [SN_FWD_WIDTH-1:0] idata_r = 0;
        
        always @(posedge clk) begin
            if (!rst) begin
                rd_en_r <= rd_en;
                wr_en_r <= wr_en;
                addr_r <= addr;
                idata_r <= idata;
            end else begin
                rd_en_r <= 0;
                wr_en_r <= 0;
                addr_r <= 0;
                idata_r <= 0;
            end
        end
        
        assign rd_en_i = rd_en_r;
        assign wr_en_i = wr_en_r;
        assign addr_i = addr_r;
        assign idata_i = idata_r;
        
    end else begin
        assign rd_en_i = rd_en;
        assign wr_en_i = wr_en;
        assign addr_i = addr;
        assign idata_i = idata;
    end
endgenerate

    /****************/
    /**Do the logic**/
    /****************/

    wire [ADDR_WIDTH-1:0] addrb;
    assign addrb = addr_i + 1;

    //Now instantiate the BRAM
    dp_bram # (
        .ADDR_WIDTH(ADDR_WIDTH),
        .PORT_WIDTH(PORT_WIDTH)
    ) mem (
        .clk(clk),
        
        .en(rd_en_i || wr_en_i), //@0
        
        .addra(addr_i), //@0
        .addrb(addrb), //@0

        .dia(idata_i[SN_FWD_WIDTH-1:PORT_WIDTH]), //@0
        .dib(idata_i[PORT_WIDTH-1:0]), //@0
        .wr_en(wr_en_i), //@0
        
        .doa(odata_i[SN_FWD_WIDTH-1:PORT_WIDTH]), //@1
        .dob(odata_i[PORT_WIDTH-1:0]) //@1
    );
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    
    //Select whether the outputs are buffered or not
generate
    if (BUF_OUT) begin
        reg [SN_FWD_WIDTH-1:0] odata_r = 0;
        
        always @(posedge clk) begin
            if (!rst) begin
                odata_r <= odata_i;
            end else begin
                odata_r <= 0;
            end
        end
        
        assign odata = odata_r;
        
    end else begin
        assign odata = odata_i;
    end
endgenerate

endmodule
