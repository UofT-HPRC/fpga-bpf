`timescale 1ns / 1ps

`include "sn_width_adapter.v"

module sn_width_adapter_tb # (
    parameter OUT_WIDTH = 64,
    parameter IN_WIDTH = 32,
    parameter OUT_ADDR_WIDTH = 9,
    parameter IN_ADDR_WIDTH = 10,
    parameter INC_WIDTH = 8
) ();
    reg clk = 0;
    reg rst = 0;
    
    //Outputs from snooper
    reg [IN_ADDR_WIDTH-1:0] in_addr = 0;
    reg [IN_WIDTH-1:0] in_wr_data = 0;
    reg in_wr_en = 0;
    reg [INC_WIDTH-1:0] in_byte_inc = 0;
    reg in_done = 0;
    
    //Inputs to packet mem
    wire [OUT_ADDR_WIDTH-1:0] out_addr;
    wire [OUT_WIDTH-1:0] out_wr_data;
    wire out_wr_en;
    wire [INC_WIDTH-1:0] out_byte_inc;
    wire out_done;
    
    integer fd, dummy;
    
    initial begin
        $dumpfile("sn_width_adapter.vcd");
        $dumpvars;
        $dumplimit(512000);
        
        clk <= 0;
        //Initial values for your other variables
        
        fd = $fopen("sn_width_adapter_drivers.mem", "r");
        if (fd == 0) begin
            $display("Could not open file");
            $finish;
        end
        
        while ($fgetc(fd) != "\n") begin
            if ($feof(fd)) begin
                $display("Error: file is in incorrect format");
                $finish;
            end
        end
        
        #4000 $finish;
    end
    
    always #5 clk <= ~clk;
    
    always @(posedge clk) begin
        
        if ($feof(fd)) begin
            $display("Reached end of drivers file");
            #20
            $finish;
        end
        
        #0.01
        dummy = $fscanf(fd, "%b%d%x%b%d%b", 
            rst,
            in_addr,
            in_wr_data,
            in_wr_en,
            in_byte_inc,
            in_done
        );
    end

    sn_width_adapter DUT #(
        .OUT_WIDTH(OUT_WIDTH),
        .IN_WIDTH(IN_WIDTH),
        .OUT_ADDR_WIDTH(OUT_ADDR_WIDTH),
        .IN_ADDR_WIDTH(IN_ADDR_WIDTH),
        .INC_WIDTH(INC_WIDTH)
    )(
		.clk(clk),
		.rst(rst),
    
        //Outputs from snooper
		.in_addr(in_addr),
		.in_wr_data(in_wr_data),
		.in_wr_en(in_wr_en),
		.in_byte_inc(in_byte_inc),
		.in_done(in_done),
    
        //Inputs to packet mem
		.out_addr(out_addr),
		.out_wr_data(out_wr_data),
		.out_wr_en(out_wr_en),
		.out_byte_inc(out_byte_inc),
		.out_done(out_done)
    );

endmodule
