`timescale 1ns / 1ps

/*

stage1.v

Implements the decode stage. Also responsible for a few datapath signals:
        - B_sel, ALU_sel, ALU_en
        - addr_sel, rd_en
        - regfile_sel, regfile_wr_en
        - imm_stage1
    
This is the most complicated stage, since it must also deal with buffered 
handshaking.

Note: the outputs of a stage are combinational on the inputs. All the "hot" bus 
signals (such as write enables) are only asserted on the single cycle when 
valid and ready are high (on the input side).

*/

`ifdef FROM_CONTROLLER
`include "../../bpf_defs.vh"
`else /* For Vivado */
`include "bpf_defs.vh"
`endif

module stage1 (
    input wire clk,
    input wire rst,
    
    input wire [63:0] instr_in,
    input wire branch_mispredict,
    
    //Outputs from this stage:
    output wire B_sel,
    output wire [3:0] ALU_sel,
    output wire ALU_en,
    output wire addr_sel,
    output wire rd_en,
    output wire regfile_sel,
    output wire regfile_wr_en,
    output wire imm_stage1,
    
    //Outputs for next stage (registered in this module):
    //Simplification: just output the instruction and let stage 2 do the thinking
    output wire [63:0] instr_out,
    
    //count number of cycles instruction has been around for
    input wire [5:0] icount,
    output wire [5:0] ocount,
    
    //Handshaking signals
    input wire prev_vld,
    output wire rdy,
    input wire next_rdy,
    output wire vld
);
    
    /************************************/
    /**Forward-declare internal signals**/
    /************************************/
    
    wire [63:0] instr_in_i;
    wire branch_mispredict_i;
    
    wire B_sel_i;
    wire [3:0] ALU_sel_i;
    wire ALU_en_i;
    wire addr_sel_i;
    wire rd_en_i;
    wire regfile_sel_i;
    wire regfile_wr_en_i;
    wire imm_stage1_i;
    
    wire [63:0] instr_out_i;
    
    wire [5:0] icount_i;
    wire [5:0] ocount_i;
    
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    
    assign instr_in_i = instr_in;
    assign branch_mispredict_i = branch_mispredict;
    
    assign icount_i = icount_i;
    
    //I thought about doing internal signals for the handshaking signals, but
    //then decided against it. Somehow it didn't seem right?
    
    
    /************************************/
    /**Helpful names for neatening code**/
    /************************************/
    
    assign opcode = instr_in_i[55:48];
    wire [2:0] opcode_class;
    assign opcode_class = opcode[2:0];
    wire [2:0] addr_type;
    assign addr_type = opcode[7:5];
    wire [2:0] jmp_type;
    assign jmp_type = opcode[6:4];
    wire [4:0] miscop;
    assign miscop = opcode[7:3];
    wire [1:0] retval;
    assign retval = opcode[4:3];
    
    
    /****************/
    /**Do the logic**/
    /****************/
    
    //More easy stuff: a lot of control signals come straight from opcode bits
    assign B_sel_i = opcode[3];
    
    assign ALU_sel_i = opcode[7:4];
    assign addr_sel_i = (addr_type == `BPF_IND) ? `PACK_ADDR_IND : `PACK_ADDR_ABS;
    
    always @(*) begin
        if ((opcode_class == `BPF_LD) && (addr_type == `BPF_ABS || addr_type == `BPF_IND)) begin
            rd_en_i <= 1;
        end else if ((opcode_class == `BPF_LDX) && (addr_type == `BPF_ABS || addr_type == `BPF_IND || addr_type == `BPF_MSH)) begin
            rd_en_i <= 1;
        end else begin
            rd_en_i <= 0;
        end
    end
    
    assign regfile_sel_decoded_i = (opcode_class == `BPF_STX) ? `REGFILE_IN_X : `REGFILE_IN_A;
    assign regfile_wr_en_decoded_i = (opcode_class == `BPF_ST || opcode_class == `BPF_STX);
    
    assign imm_stage1_i = instr_in_i[31:0];
    
    assign instr_out_i = instr_in_i;
    
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    
    //This performs the buffered handshaking on the outputs (instr_out and ocount)
    bhand # (
        .DATA_WIDTH(64),
        .ENABLE_COUNT(1),
        .COUNT_WIDTH(6)
    ) delay_stage (
        .clk(clk),
        .rst(rst || branch_mispredict_i),
            
        .idata(instr_out_i),
        .idata_vld(prev_vld),
        .idata_rdy(rdy),
            
        .odata(instr_out),
        .odata_vld(vld),
        .odata_rdy(next_rdy),
        
        .icount(ocount_i),
        .ocount(ocount)
    );
    
    //This stage's control bus outputs
    //Note that "hot" control signals are gated with prev_vld and rdy
    wire enable_hot;
    assign enable_hot = prev_vld && rdy;
    
    assign B_sel          = B_sel_i;
    assign ALU_sel        = ALU_sel_i;
    assign ALU_en         = ALU_en_i && enable_hot;
    assign addr_sel       = addr_sel_i;
    assign rd_en          = rd_en_i && enable_hot;
    assign regfile_sel    = regfile_sel_i;
    assign regfile_wr_en  = regfile_wr_en_i && enable_hot;
    assign imm_stage1     = imm_stage1_i;

endmodule
