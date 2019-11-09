`timescale 1ns / 1ps
/*
alu.v
A simple ALU designed to match the needs of the BPF VM. 
*/


module alu # (
	parameter PESS = 0
)(
	input wire clk,
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] ALU_sel,
    input wire ALU_en,
    output wire [31:0] ALU_out,
    output wire set,
    output wire eq,
    output wire gt,
    output wire ge,
    output wire ALU_vld
);

    /************************************/
    /**Forward-declare internal signals**/
    /************************************/
    wire [31:0] A_i;
    wire [31:0] B_i;
    wire [3:0] ALU_sel_i;
    wire ALU_en_i;
    wire [31:0] ALU_out_i = 0;
    wire eq_i, gt_i, ge_i, set_i;
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    
    assign A_i = A;
    assign B_i = B;
    assign ALU_sel_i = ALU_sel;
    assign ALU_en_i = ALU_en;
    
    /****************/
    /**Do the logic**/
    /****************/
    
    
    always @(*) begin
        case (ALU_sel_i)
            4'h0:
                ALU_out_i <= A_i + B_i;
            4'h1:
                ALU_out_i <= A_i - B_i;
            4'h2:
                //ALU_out <= A_i * B_i; //TODO: what if this takes >1 clock cycle?
                ALU_out_i <= 32'hCAFEDEAD; //For simplicity, return an "error code" to say "modulus not supported"
            4'h3:
                /*
                ALU_out <= A_i / B_i; //TODO: what if B_i is zero?
                                  //TODO: what if this takes >1 clock cycle?
                */
                ALU_out_i <= 32'hDEADBEEF; //For simplicity, return an "error code" to say "division not supported"
            4'h4:
                ALU_out_i <= A_i | B_i;
            4'h5:
                ALU_out_i <= A_i & B_i;
            4'h6:
                ALU_out_i <= A_i << B_i; //TODO: does this work?
            4'h7:
                ALU_out_i <= A_i >> B_i; //TODO: does this work?
            4'h8:
                ALU_out_i <= ~A_i;
            4'h9:
                /*
                ALU_out <= A_i % B_i; //TODO: what if B_i is zero?
                                  //TODO: what if this takes >1 clock cycle?
                */
                ALU_out_i <= 32'hBEEFCAFE; //For simplicity, return an "error code" to say "modulus not supported"
            4'hA:
                ALU_out_i <= A_i ^ B_i;
            default:
                ALU_out_i <= 32'd0;
        endcase
    end


    //These are used as the predicates for JMP instructions
    assign eq_i = (A == B) ? 1'b1 : 1'b0;
    assign gt_i = (A > B) ? 1'b1 : 1'b0;
    assign ge_i = gt_i | eq_i;
    assign set_i = ((A & B) != 32'h00000000) ? 1'b1 : 1'b0;

    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
generate
    if (PESS) begin
        reg eq_r, gt_r, ge_r, set_r;
        always @(posedge clk) begin
            eq_r <= eq_i;
            gt_r <= gt_i;
            ge_r <= ge_i;
            set_r <= set_i;
        end
        assign eq = eq_r;
        assign gt = gt_r;
        assign ge = ge_r;
        assign set = set_r;
        
        reg [31:0] ALU_out_r;
        always @(posedge clk) begin
            ALU_out_r <= ALU_out_i;
        end
        assign ALU_out = ALU_out_r;
    end else begin
        assign eq = eq_i;
        assign gt = gt_i;
        assign ge = ge_i;
        assign set = set_i;
        
        assign ALU_out = ALU_out_i;
    end
endgenerate

endmodule
