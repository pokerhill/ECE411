module instr_fetch

import rv32i_types::*;
(
	input clk,
	input rst,
	// inputs from memory stage
	input logic [31:0] alu_out_mem,
	input logic cmp_out_mem,
	input rv32i_control_word control_word_in,
//	input logic br_pred_taken_mem_stage,
	input logic stall_pc,
	//input rv32i_word br_pred_pc,
	input logic checker_taken,
	input rv32i_word pc_mem_stage,
	input logic checker_mispredicted,
	input rv32i_word mispredicted_new_pc,
	input rv32i_word i_cache_rdata,
	input logic update_hist_table,
	input logic br_taken_mem,
//	input logic flush,
	//input rv32i_word instr_mem_rdata_in,

	//output logic br_pred_stall_pc,
	//output logic br_pred_stall_nop,
	//input logic br_actually_taken,
	//input rv32i_word pc_mem_stage,
	output logic br_pred_taken,
	output rv32i_word br_pred_pc_out,

	// outputs to decode stage
	//output  rv32i_word 	instr_mem_rdata_out,
	//output logic [31:0] instr_data;
	output logic [31:0] pc_out_fetch,
	output logic [31:0] pcp4_out_fetch
);

// create local variables
logic [31:0] pcmux_out;
logic [31:0] pcreg_val;
logic [31:0] pc_sel_out;
assign pcp4_out_fetch = pcreg_val + 32'h00000004;
assign pc_out_fetch = pcreg_val;

/******** PC ********/
pc_register PC (
	.clk	(clk),
	.rst	(rst),
	.load	(~stall_pc),
	.in		(pc_sel_out),
	.out	(pcreg_val)
);

logic br_pred_taken_temp;
//logic br_pred_taken_temp_2;

br_pred_blkbox BR_PREDICTOR (
	.clk(clk),
	.rst(rst),
	.read((i_cache_rdata[6:0] == 7'h63)),
	.load(update_hist_table),
	.stall(stall_pc),
	.br_taken(br_taken_mem),
	.pc_in(pcreg_val),
	.pc_mem_stage(pc_mem_stage),
//	.stall_pc(br_pred_stall_pc),
//	.stall_nop_ifid(br_pred_stall_nop_temp),
	.flush(br_pred_taken)
);




/******** MUXES ********/
always_comb begin : MUXES
	/*
	if (br_taken_mem == 1 && ) begin
		br_pred_taken_temp = 1'b0;
	end
	*/
	if (br_pred_taken && i_cache_rdata[6:0] == 7'h63) begin
		br_pred_pc_out = pcreg_val + {{20{i_cache_rdata[31]}}, i_cache_rdata[7], i_cache_rdata[30:25], i_cache_rdata[11:8], 1'b0};
	end
	
	if (checker_taken) 
		br_pred_taken_temp = 1'b0;
	else
		br_pred_taken_temp = br_pred_taken;	

	// may be able to condense this further....
	unique case ({br_pred_taken_temp, checker_taken, control_word_in.pcmux_sel})
		4'b0000: pcmux_out = pcreg_val + 32'h00000004;
		4'b0001: pcmux_out = alu_out_mem;
		4'b0010: pcmux_out = {alu_out_mem[31:1], 1'b0};
		4'b0011: pcmux_out = pcreg_val + 32'h00000004;
		4'b0100: pcmux_out = alu_out_mem; //pcreg_val + 32'h00000004;
		4'b0101: pcmux_out = alu_out_mem;
		4'b0110: pcmux_out = {alu_out_mem[31:1], 1'b0};
		4'b0111: pcmux_out = alu_out_mem;
		4'b1000: pcmux_out = br_pred_pc_out;
		4'b1001: pcmux_out = br_pred_pc_out;
		4'b1010: pcmux_out = br_pred_pc_out;
		4'b1011: pcmux_out = br_pred_pc_out;
		4'b1100: pcmux_out = br_pred_pc_out;
		4'b1101: pcmux_out = br_pred_pc_out;
		4'b1110: pcmux_out = br_pred_pc_out;
		4'b1111: pcmux_out = br_pred_pc_out;
		default:;
	endcase

	unique case ({checker_mispredicted})
		//2'b00: pc_sel_out = pcmux_out;
		//2'b01: pc_sel_out = pcmux_out;
		1'b0: pc_sel_out = pcmux_out;
		1'b1: pc_sel_out = mispredicted_new_pc + 32'h00000004;
		default:;
	endcase

end



endmodule : instr_fetch
