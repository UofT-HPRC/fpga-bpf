`timescale 1ns / 1ps
`include "cpu_adapter.v"

`define BYTE_ADDR_WIDTH 12
`define ADDR_WIDTH 9
`define DATA_WIDTH (2**(`BYTE_ADDR_WIDTH - `ADDR_WIDTH)*8)


module cpu_adapter_tb;
    reg clk;
        
    reg [`BYTE_ADDR_WIDTH-1:0] byte_rd_addr;
    reg cpu_rd_en;
    reg [1:0] transfer_sz;
    wire rd_en;
    wire [`ADDR_WIDTH-1:0] word_rd_addra;
    wire cache_hit;
    wire [31:0] cached_data;
    reg [`DATA_WIDTH-1:0] bigword;
    wire [31:0] resized_mem_data;

    integer fd;
    integer dummy;

    initial begin
        $dumpfile("cpu_adapter.vcd");
        $dumpvars;
        $dumplimit(1024000);
            
        clk <= 0;
        byte_rd_addr <= 'hd;
        cpu_rd_en <= 0;
        transfer_sz <= 0;
        bigword <= 0;
        
        fd = $fopen("cpu_adapter_drivers.mem", "r");
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
        #0.01
        dummy = $fscanf(fd, "%h%b%b%h", byte_rd_addr, cpu_rd_en, transfer_sz, bigword);
    end
    
    cpu_adapter # (
        .BYTE_ADDR_WIDTH(`BYTE_ADDR_WIDTH), 
        .ADDR_WIDTH(`ADDR_WIDTH),
        .BUF_IN(0),
        .BUF_OUT(1),
        .PESS(0)
    ) DUT (
        .clk(clk),
        
        .byte_rd_addr(byte_rd_addr), 
        .cpu_rd_en(cpu_rd_en), 
        .transfer_sz(transfer_sz), 
        
        .rd_en(rd_en), 
        .word_rd_addra(word_rd_addra), 
        
        .cache_hit(cache_hit),
        .cached_data(cached_data), 
        
        .bigword(bigword),
        .resized_mem_data(resized_mem_data)
    );

endmodule
