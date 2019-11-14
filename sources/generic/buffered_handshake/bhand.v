`timescale 1ns / 1ps

//Implements a buffered handshake

module bhand # (
    parameter DATA_WIDTH = 8
) (
    input wire clk,
    input wire rst,
    
    input wire [DATA_WIDTH-1:0] idata,
    input wire idata_vld,
    output wire idata_rdy,
    
    output wire [DATA_WIDTH-1:0] odata,
    output wire odata_vld,
    input wire odata_rdy
);

    //Some helper signals for neatening up the code
    wire shift_in;
    assign shift_in = idata_vld && idata_rdy;
    
    wire shift_out;
    assign shift_out = odata_vld && odata_rdy;
    
    
    
    //Forward-declare this signal since extra_mem needs it
    reg mem_vld = 0;
    
    
    
    //Internal registers and signals for extra element
    reg [DATA_WIDTH-1:0] extra_mem = 0;
    reg extra_mem_vld = 0;
    wire extra_mem_rdy;
    
    //Unlike a regular FIFO, we are only ready if empty:
    assign extra_mem_rdy = (extra_mem_vld == 0);
    
    //We will enable writing into extra mem if a new element is shifting in AND
    //mem is full AND mem will not be read on this cycle
    wire extra_mem_en;
    assign extra_mem_en = shift_in && mem_vld && !shift_out;
    
    always @(posedge clk) begin
        if (rst) begin
            mem <= 0;
            mem_vld <= 0;
        end else begin
            //extra_mem's next value
            if (extra_mem_en) begin
                extra_mem <= idata;
            end
            
            //extra_mem_vld's next value
            if (extra_mem_en) begin
                extra_mem_vld <= 1;
            end else if (shift_out) begin
                extra_mem_vld <= 0;
            end
        end
    end
    
    
    
    //Internal registers and signals for FIFO element
    reg [DATA_WIDTH-1:0] mem = 0;
    //reg mem_vld = 0; //moved
    wire mem_rdy;
    
    //We are ready if FIFO is empty, or if the value is leaving on this cycle
    assign mem_rdy = !mem_vld || (odata_vld && odata_rdy);
    
    //We will enable writing into mem if it is ready, and if the input is valid
    wire mem_en;
    assign mem_en = mem_rdy && (idata_vld || extra_mem_vld);
    
    always @(posedge clk) begin
        if (rst) begin
            extra_mem <= 0;
            extra_mem_vld <= 0;
        end else begin
            //mem's next value
            if (mem_en) begin
                mem <= extra_mem_vld ? extra_mem : idata;
            end
            
            //mem_vld's next value
            if (mem_en) begin
                mem_vld <= 1;
            end else if (shift_out) begin
                mem_vld <= 0;
            end
        end
    end
    
    
    
    //Actually wire up module outputs
    assign idata_rdy = extra_mem_rdy;
    assign odata = mem;
    assign odata_vld = mem_vld;
    
endmodule
