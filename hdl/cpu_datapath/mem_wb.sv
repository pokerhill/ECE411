module mem_wb

import rv32i_types::*;
(
	input clk,
	input rst,

	// inputs from memory stage
	input rv32i_control_word cntrl_word_in,
	input logic cmp_val_in,
	input rv32i_word alu_val_in,
	input rv32i_word reg_pc_in,
	input rv32i_reg reg_dest_in,
	input rv32i_word u_imm_in,
	input rv32i_word r_data_in,
	input stall,
	// outputs to wb stage
	output rv32i_word u_imm_out,
	output rv32i_reg reg_dest_out,
	output rv32i_word reg_pc_out,
	output rv32i_word alu_val_out,
	output logic cmp_val_out,
	output rv32i_control_word cntrl_word_out,
	output rv32i_word r_data_out,
	
	input rv32i_opcode opcode_in,
	output rv32i_opcode opcode_out
);

//assign opcode_out = opcode_in;

always_ff @(posedge clk) begin
	if (rst) begin
	u_imm_out <= rv32i_word'(32'b0);
	reg_dest_out <= rv32i_reg'(5'b0);
	reg_pc_out <= rv32i_word'(32'b0);
	alu_val_out <= rv32i_word'(32'b0);
	cmp_val_out <=1'b0;
	cntrl_word_out <=rv32i_control_word'(1'b0);
	r_data_out <= rv32i_word'(32'b0);
	opcode_out <= opcode_in;
	end
	else begin
	if (~stall) begin
		u_imm_out <=u_imm_in ;
		reg_dest_out <=reg_dest_in ;
		reg_pc_out <=reg_pc_in ;
		alu_val_out <=alu_val_in ;
		cmp_val_out <= cmp_val_in ;
		r_data_out <=r_data_in ;
		cntrl_word_out <= cntrl_word_in;
		opcode_out <= opcode_in;
	end
	end

end

endmodule : mem_wb
