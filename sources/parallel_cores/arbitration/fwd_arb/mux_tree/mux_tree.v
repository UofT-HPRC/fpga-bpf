`timescale 1ns / 1ps

/*
mux_tree.v

*/

`ifdef FROM_MUX_TREE
`include "mux_tree_node/mux_tree_node.v"
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

`CLOG4(x) ((`CLOG2(x)+1)/2)

module mux_tree # (
    parameter N = 4,
    parameter WIDTH = 8,
    
    //Auto-derived parameters. Do not set
	parameter PADDED = (N%3 == 1) ? N : ((N%3 == 0) ? (N+1) : (N+2)),
	parameter TAG_SZ = 2*`CLOG4(PADDED) //= 2 * ceil(log_4(PADDED))
) (
    input wire clk,
    input wire rst,
    
    input wire [TAG_SZ-1:0] sel,
    input wire [N*WIDTH-1:0] ins,
    output wire [WIDTH-1:0] out
    
);
    
    //Quick draft to give me an idea of how this will work
	parameter MAX_H = TAG_SZ/2;
	parameter NUM_NODES = PADDED + (PADDED-1)/3;
	parameter X_C = NUM_NODES - (4**MAX_H - 1) / 3; 
    
    reg [TAG_SZ-1:0] delayed_sel[0:MAX_H-1];
    
    
    wire [WIDTH-1:0] nodes[0:NUM_NODES-1];
    
    //pseudocode!
    assign delayed_sel[0] = sel;
    for (i = 1; i < MAX_H; i++) {
        reg [TAG_SZ-1:0] delayed = 0;
        always @(posedge clk) begin
            if (rst) begin
                delayed <= 0;
            end else begin
                delayed <= delayed_sel[i-1];
            end
        end
        assign delayed_sel[i] = delayed;
    }
    
    //long path nodes
    for (i = 0; i < X_C; i++) {
        assign nodes[i] = ins[WIDTH*(i+1) -1 -: WIDTH];
    }
    //short path nodes
    for (i = X_C; i < N; i++) {
        reg [WIDTH-1:0] delayed;
        always @(posedge clk) begin
            if (rst) begin
                delayed <= 0;
            end else begin
                delayed <= ins[WIDTH*(i+1) -1 -: WIDTH];
            end
        end
        
        assign nodes[i] = delayed;
    }
    
    //padding to one more than a multiple of 3
    for (i = N; i < PADDED; i++) {
        assign nodes[i] = 0;
    }
    
    //construct tree
    for (i = 0; i < (N-1)/3; i++) {
        parameter H = `CLOG4(NUM_NODES - i - 1);
        mux_tree_node(
            .sel(delayed_sel[H][MAX_H-H-1 -: 2]),
            .A(nodes[4*i]),
            .B(nodes[4*i+1]),
            .C(nodes[4*i+2]),
            .D(nodes[4*i+3]),
            .result(nodes[N+i])
        );
    }
    
    

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

`undef CLOG2
