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

TODO: At some point I'll write logic to detect when this stage is stalled. 
Importantly, this needs to gate the output valid signal, and the output-side 
ready signal on the bhand module.

*/

//temporary: remove this
`define FROM_CONTROLLER 1

`ifdef FROM_CONTROLLER
`include "../../bpf_defs.vh"
`include "../../../generic/buffered_handshake/bhand.v"
`else /* For Vivado */
`include "bpf_defs.vh"
`endif

//I use logic where I intend combinational logic, but Verilog forces me to use reg
`define logic reg

module stage1 (
    input wire clk,
    input wire rst,
    
    input wire [63:0] instr_in,
    input wire branch_mispredict,
    
    //Signals for stall logic
    input wire stage2_reads_regfile, //TODO: maybe make regfile dual port?
    input wire stage2_writes_A,
    input wire stage2_writes_X,
    
    //Outputs from this stage:
    output wire B_sel,
    output wire [3:0] ALU_sel,
    output wire ALU_en,
    output wire addr_sel,
    output wire rd_en,
    output wire [3:0] regfile_sel_stage1,
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
    
    wire stalled_i;
    
    wire [63:0] instr_in_i;
    wire branch_mispredict_i;
    
    wire B_sel_i;
    wire [3:0] ALU_sel_i;
    wire ALU_en_i;
    wire addr_sel_i;
    `logic rd_en_i;
    wire regfile_sel_i;
    wire regfile_wr_en_i;
    wire imm_stage1_i;
    
    wire [63:0] instr_out_i;
    
    wire [5:0] icount_i;
    wire [5:0] ocount_i;
    
    wire prev_vld_i;
    wire rdy_i;
    wire next_rdy_i;
    wire vld_i;
    
    
    /***************************************/
    /**Assign internal signals from inputs**/
    /***************************************/
    
    assign instr_in_i = instr_in;
    assign branch_mispredict_i = branch_mispredict;
    
    assign icount_i = icount_i;
    
    assign prev_vld_i = prev_vld;
    assign next_rdy_i = next_rdy;
    
    
    /************************************/
    /**Helpful names for neatening code**/
    /************************************/
    
    //Named subfields of opcode
    wire [7:0] opcode;
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
    
    //Helper booleans 
    wire miscop_is_zero;
    assign miscop_is_zero = (miscop == 0);
    wire is_TAX_instruction;
    assign is_TAX_instruction = (opcode_class == `BPF_MISC) && (miscop_is_zero);
    wire is_TXA_instruction;
    assign is_TXA_instruction = (opcode_class == `BPF_MISC) && (!miscop_is_zero);
    wire is_RETA_instruction;
    assign is_RETA_instruction = (opcode_class == `BPF_RET) && (retval == `RET_A);
    wire is_RETX_instruction;
    assign is_RETX_instruction = (opcode_class == `BPF_RET) && (retval == `RET_X);
    wire is_RETIMM_instruction;
    assign is_RETIMM_instruction = (opcode_class == `BPF_RET && retval == `RET_IMM);
    
    //For determining when we are stalled
    wire we_read_A; 
    assign we_read_A = (opcode_class == `BPF_ALU) || (opcode_class == `BPF_JMP) || (opcode_class == `BPF_ST) || (is_RETA_instruction) || (is_TAX_instruction);
    wire we_read_X;
    assign we_read_X = ((opcode_class == `BPF_LD || opcode_class == `BPF_LDX) && addr_type == `BPF_IND) || (opcode_class == `BPF_STX) || (is_RETX_instruction) || (is_TXA_instruction);

    
    /****************/
    /**Do the logic**/
    /****************/
    
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
    
    assign regfile_sel_i = (opcode_class == `BPF_STX) ? `REGFILE_IN_X : `REGFILE_IN_A;
    assign regfile_wr_en_i = (opcode_class == `BPF_ST || opcode_class == `BPF_STX);
    
    assign imm_stage1_i = instr_in_i[31:0];
    
    assign instr_out_i = instr_in_i;
    
    assign ocount_i = icount_i;
    
    //Stall signals
    assign stalled_i = 
                        (we_read_A && stage2_writes_A)
                      ||(we_read_X && stage2_writes_X)
                      ||(regfile_wr_en_i && stage2_reads_regfile);
    
    //This performs the buffered handshaking
    bhand # (
        .DATA_WIDTH(64),
        .ENABLE_COUNT(1),
        .COUNT_WIDTH(6)
    ) delay_stage (
        .clk(clk),
        .rst(rst || branch_mispredict_i),
            
        .idata(instr_in_i),
        .idata_vld(prev_vld_i),
        .idata_rdy(rdy_i),
            
        .odata(instr_out_i),
        .odata_vld(vld_i),
        .odata_rdy(next_rdy_i),
        
        .icount(icount_i),
        .ocount(ocount_i)
    );
    
    /****************************************/
    /**Assign outputs from internal signals**/
    /****************************************/
    

    
    //This stage's control bus outputs
    //Note that "hot" control signals are gated with prev_vld and rdy and not stalled
    wire enable_hot;
    assign enable_hot = prev_vld && rdy && !stalled_i;
    
    assign B_sel          = B_sel_i;
    assign ALU_sel        = ALU_sel_i;
    assign ALU_en         = ALU_en_i && enable_hot;
    assign addr_sel       = addr_sel_i;
    assign rd_en          = rd_en_i && enable_hot;
    assign regfile_sel    = regfile_sel_i;
    assign regfile_wr_en  = regfile_wr_en_i && enable_hot;
    assign imm_stage1     = imm_stage1_i;
    
    //Handshaking signals
    //We are not ready if we are stalled
    assign vld = vld_i;
    assign rdy = rdy_i && !stalled_i;

endmodule
