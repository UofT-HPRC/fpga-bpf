`timescale 1ns / 1ps

/*
axistream_packetfilt_tb.v

Just forces the inst_addr, inst_data, and inst_rd_en ports to avoid dealing with
a simulation of AXI Lite
*/

`ifdef FROM_AXISTREAM_PACKETFILT
`include "axistream_packetfilt.v"
`define forcer force
`define lacher release
`else /*For Vivado*/
`define forcer
`define lacher
`endif

module axistream_packetfilt_tb;
	reg clk;
    //Other variables connected to your instance
    
    integer fd, dummy;
    
    initial begin
        $dumpfile("axistream_packetfilt.vcd");
        $dumpvars;
        $dumplimit(512000);
        
        clk <= 0;
        //Initial values for your other variables
        
        fd = $fopen("axistream_packetfilt_drivers.mem", "r");
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
    end
    
    always #5 clk <= ~clk;
    
    always @(posedge clk) begin
        if ($feof(fd)) begin
            $display("Reached end of drivers file");
            #20
            $finish;
        end
        
        #0.01
        dummy = $fscanf(fd, "%F%O%R%M%A%T", /* list of variables */);
    end

    mymodule DUT (
        .clk(clk),
        ...
    );


endmodule
