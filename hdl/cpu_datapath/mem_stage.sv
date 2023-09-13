module mem_stage

import rv32i_types::*;
(
	// input clk,
	// input rst,

	input rv32i_control_word cntrl_word_in,
	input logic cmp_val_in,
	input rv32i_word alu_in,
	input rv32i_word reg_pc_in,
	input rv32i_reg reg_dest_in,
	input rv32i_word u_imm_in,
	input logic [2:0] funct3_in,
	input rv32i_word rs2_data_in, 
	input rv32i_word r_data_MemWb_in,  //used for foward path out of writeback
	input logic br_pred_taken_in,

	input cachemux::cachemux_sel_t cachemux_sel,

	output rv32i_word forwarding_val_out,
	output rv32i_word u_imm_out,
	output rv32i_reg reg_dest_out,
	output rv32i_word reg_pc_out,
	output rv32i_word alu_out,
	output logic cmp_val_out,
	output rv32i_control_word cntrl_word_out,
	output rv32i_word wdata_out,
	output logic [3:0] mem_byte_enable,
	output logic checker_mispredicted_out,
	output logic flush,
	output logic update_br_pred_taken_out,
	//output logic update_hist_table,

	input rv32i_opcode opcode_in,
	output rv32i_opcode opcode_out
);
	
	assign opcode_out = opcode_in;

	// handle funct3
	store_funct3_t store_funct3;
	assign store_funct3 = store_funct3_t'(funct3_in);
	

	// values we are passing through this stage
	assign reg_pc_out = reg_pc_in; 
	assign u_imm_out = u_imm_in;
    assign reg_dest_out = reg_dest_in;
	assign cmp_val_out = cmp_val_in;
    assign alu_out = alu_in;
    assign cntrl_word_out = cntrl_word_in;


	
/******** BRANCH PREDICTOR ********/
static_nt_predictor BR_CHECKER (
	// .clk(clk),
	// .rst(rst),
	.cmp_out(cmp_val_in),
	.opcode(opcode_in),
	.br_pred_taken(br_pred_taken_in),
	.mispredicted(checker_mispredicted_out),
	.flush(flush),
	.update_br_pred_taken(update_br_pred_taken_out)
	//.update_hist_table(update_hist_table)
);




always_comb begin
	// select the rs2 value or the forwarding path data
	case (cachemux_sel)
		 cachemux::r_data_MemWb: wdata_out = r_data_MemWb_in;
		 cachemux::rs2_out_ExMem: wdata_out = rs2_data_in; 
	endcase

	unique case (cntrl_word_in.regfilemux_sel) 
		regfilemux::alu_out: forwarding_val_out = alu_in;
		regfilemux::br_en: forwarding_val_out = {31'b0, cmp_val_in};
		regfilemux::u_imm: forwarding_val_out = u_imm_in;
		regfilemux::pc_plus4: forwarding_val_out = reg_pc_in + 4;
		default: forwarding_val_out = 32'b0;
	endcase



	// get the mem_byte_enable / MBE Generator
	if (opcode_in == op_store) begin
		case(store_funct3) 
			sw: mem_byte_enable = 4'b1111;   
			sh: mem_byte_enable = {alu_in[1],alu_in[1],~alu_in[1],~alu_in[1]}; //0 or 2
			sb: begin 
				case (alu_in[1:0]) //0 1 2 3
					2'b00: mem_byte_enable = 4'b0001;
					2'b01: mem_byte_enable = 4'b0010;
					2'b10: mem_byte_enable = 4'b0100;
					2'b11: mem_byte_enable = 4'b1000;
				endcase
				end
		endcase


		// store rearranger
		case (store_funct3)
			sw: wdata_out = rs2_data_in;
			sh: begin 
				case (alu_in[1]) //0 1 2 3
					1'b1: wdata_out = {rs2_data_in[15:0],{16{1'b0}}};
					1'b0: wdata_out = {{16{1'b0}},rs2_data_in[15:0]};
				endcase
		    	end
			sb: begin 
				case (alu_in[1:0]) //0 1 2 3
					2'b00: wdata_out = {{24{1'b0}}, rs2_data_in[7:0]};
					2'b01: wdata_out = {{16{1'b0}}, rs2_data_in[7:0], {8{1'b0}}};
					2'b10: wdata_out = {{8{1'b0}}, rs2_data_in[7:0], {16{1'b0}}};
					2'b11: wdata_out = {rs2_data_in[7:0], {24{1'b0}}};
					endcase
				end
		endcase
	end
/*
	// select the rs2 value or the forwarding path data
	case (cachemux_sel)
		 cachemux::r_data_MemWb: wdata_out = r_data_MemWb_in;
		 cachemux::rs2_out_ExMem: wdata_out = rs2_data_in; 
	endcase
*/
end

endmodule : mem_stage
