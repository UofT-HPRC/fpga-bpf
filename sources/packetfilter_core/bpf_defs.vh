//Please remember to set this as "global include" in Vivado's sources panel

`ifndef BPF_DEFS_VH
`define BPF_DEFS_VH 1

/* instruction classes */
`define		BPF_LD		3'b000
`define		BPF_LDX		3'b001
`define		BPF_ST		3'b010
`define		BPF_STX		3'b011
`define		BPF_ALU		3'b100
`define		BPF_JMP		3'b101
`define		BPF_RET		3'b110
`define		BPF_MISC	3'b111

/* ld/ldx fields */
//Fetch size 
`define		BPF_W		2'b00 //Word, half-word, and byte
`define		BPF_H		2'b01
`define		BPF_B		2'b10
//Addressing mode
`define		BPF_IMM 	3'b000 
`define		BPF_ABS		3'b001
`define		BPF_IND		3'b010 
`define		BPF_MEM		3'b011
`define		BPF_LEN		3'b100
`define		BPF_MSH		3'b101
//Named constants for A register MUX
`define		A_SEL_IMM 	3'b000
`define		A_SEL_ABS	3'b001
`define		A_SEL_IND	3'b010 
`define		A_SEL_PACKET_MEM	`A_SEL_ABS 
`define		A_SEL_MEM	3'b011
`define		A_SEL_LEN	3'b100
`define		A_SEL_MSH	3'b101
`define		A_SEL_ALU	3'b110
`define		A_SEL_X		3'b111
//Named constants for X register MUX
`define		X_SEL_IMM 	3'b000 
`define		X_SEL_ABS	3'b001
`define		X_SEL_IND	3'b010 
`define		X_SEL_PACKET_MEM	`X_SEL_ABS
`define		X_SEL_MEM	3'b011
`define		X_SEL_LEN	3'b100
`define		X_SEL_MSH	3'b101
`define		X_SEL_A		3'b111
//Absolute or indirect address select
`define		PACK_ADDR_ABS	1'b0
`define		PACK_ADDR_IND	1'b1
//A or X select for regfile write
`define		REGFILE_IN_A	1'b0
`define		REGFILE_IN_X	1'b1
//ALU operand B select
`define		ALU_B_SEL_IMM	1'b0
`define		ALU_B_SEL_X		1'b1
//ALU operation select
`define		BPF_ADD		4'b0000
`define		BPF_SUB		4'b0001
`define		BPF_MUL		4'b0010
`define		BPF_DIV		4'b0011
`define		BPF_OR		4'b0100
`define		BPF_AND		4'b0101
`define		BPF_LSH		4'b0110
`define		BPF_RSH		4'b0111
`define		BPF_NEG		4'b1000
`define		BPF_MOD		4'b1001
`define		BPF_XOR		4'b1010
//Jump types
`define		BPF_JA		3'b000
`define		BPF_JEQ		3'b001
`define		BPF_JGT		3'b010
`define		BPF_JGE		3'b011
`define		BPF_JSET	3'b100
//Compare-to value select
`define		BPF_COMP_IMM	1'b0
`define 	BPF_COMP_X		1'b1
//PC value select
`define		PC_SEL_PLUS_1	2'b00
`define		PC_SEL_PLUS_JT	2'b01
`define		PC_SEL_PLUS_JF	2'b10
`define		PC_SEL_PLUS_IMM	2'b11
//Return register select
`define		RET_IMM		2'b00
`define		RET_X		2'b01
`define		RET_A		2'b10


`endif
