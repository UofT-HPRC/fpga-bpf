`timescale 1ns / 1ps

`ifdef FROM_SN_ADAPTER
`include "sn_adapter.v"
`endif

module sn_adapter_tb;
    reg clk;
    reg rst;

    integer fd;
    integer dummy;

    initial begin
        $dumpfile("sn_adapter.vcd");
        $dumpvars;
        $dumplimit(1024000);
            
        clk <= 0;
        rst <= 0;
        
        fd = $fopen("sn_adapter_drivers.mem", "r");
        if (fd == 0) begin
            $display("Could not open file");
            $finish;
        end
        while($fgetc(fd) != "\n") begin end //Skip first line of comments
        
        #2000 $finish;
    end

    always #5 clk <= ~clk;
    
    always @(posedge clk) begin
        if ($feof(fd)) begin
            $display("Reached end of drivers file");
            #20
            $finish;
        end
        //#0.01
        //dummy = $fscanf(fd, ...);
    end

endmodule
