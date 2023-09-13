module execute
import rv32i_types::*;

(
    // input clk,    
    // input rst, 

    input rv32i_word reg_data_1_in, 
    input rv32i_word reg_data_2_in,
    input rv32i_reg rs2_id_in,
    input rv32i_word pc_reg_in,
    input rv32i_control_word cntrl_word_in,
    input rv32i_reg reg_dest_in,

    input rv32i_word i_imm_in,
    input rv32i_word s_imm_in,
    input rv32i_word b_imm_in,
    input rv32i_word u_imm_in,
    input rv32i_word j_imm_in,
	input logic[2:0] funct3_in,
	input logic br_pred_taken_in,

	// from forwarding
	input rv32i_word data_from_exmem_in,
	input rv32i_word data_from_memwb_in,
	// input for the mux select
	input alumux::alumux1_sel_t forwarding_alumux1_sel,
	input alumux::alumux2_sel_t forwarding_alumux2_sel,


    //TODO added input for cmp mux select
    input cmpmux::cmpmux1_sel_t fowarding_cmpmux1_sel,
    input cmpmux::cmpmux2_sel_t fowarding_cmpmux2_sel,

	input logic [1:0] forwarding_rs2_pass_sel,


    output rv32i_reg reg_dest_out,
    output rv32i_word u_imm_out,//double check all imm outs
    output rv32i_word alu_out,
    output logic cmp_out,
    output rv32i_word pc_reg_out,
    //output rv32i_word reg_data_2_out,
	output rv32i_word rs2passmux_out,
    output rv32i_control_word cntrl_word_out,
	output logic [2:0] funct3_out,
	output logic br_pred_taken_out,
    output rv32i_reg rs2_id_out,
	input rv32i_opcode opcode_in,
	output rv32i_opcode opcode_out

);

assign opcode_out = opcode_in;
assign cntrl_word_out = cntrl_word_in;
assign br_pred_taken_out = br_pred_taken_in;

rv32i_word mux1_out;
rv32i_word mux2_out;
rv32i_word cmpmux1_out;
rv32i_word cmpmux2_out;
assign pc_reg_out = pc_reg_in;
//assign reg_data_2_out = reg_data_2_in;
assign u_imm_out = u_imm_in;
assign reg_dest_out = reg_dest_in; 
assign funct3_out = funct3_in;
assign rs2_id_out = rs2_id_in;

/******** ALU  ********/
alu alu(
    .aluop(cntrl_word_in.aluop),
    .a(mux1_out),
    .b(mux2_out),
    .f(alu_out)
);

/******** CMP ********/

cmp cmp(
    .cmpop(cntrl_word_in.cmpop),
    .a(cmpmux1_out),
    .b(cmpmux2_out),
    .br_en(cmp_out)
);

/******** MUXES ********/

always_comb begin : MUXES

	// alumux1
	unique case (forwarding_alumux1_sel)
        alumux::rs1_out:mux1_out = reg_data_1_in;
        alumux::pc_out:mux1_out = pc_reg_in;
		alumux::alu_out_ExMem1: mux1_out = data_from_exmem_in;
		alumux::r_data_MemWb1: mux1_out = data_from_memwb_in;
		default:;
	endcase

	// alumux2
	unique case (forwarding_alumux2_sel)
        alumux:: i_imm:mux2_out = i_imm_in;
        alumux:: u_imm:mux2_out = u_imm_in;
        alumux:: b_imm:mux2_out = b_imm_in;
        alumux:: s_imm:mux2_out = s_imm_in;
        alumux:: j_imm:mux2_out = j_imm_in;
        alumux:: rs2_out:mux2_out = reg_data_2_in;
		alumux::alu_out_ExMem2: mux2_out = data_from_exmem_in;
		alumux::r_data_MemWb2: mux2_out = data_from_memwb_in;
		default:;
	endcase

	// cmpmux
	unique case (fowarding_cmpmux1_sel)
        cmpmux::rs1_out:          cmpmux1_out = reg_data_1_in;
        cmpmux::alu_out_ExMem1:   cmpmux1_out = data_from_exmem_in;
        cmpmux::r_data_MemWb1:    cmpmux1_out = data_from_memwb_in;
		default:;
	endcase

    unique case (fowarding_cmpmux2_sel)
        cmpmux::rs2_out:          cmpmux2_out = reg_data_2_in;
        cmpmux::alu_out_ExMem2:   cmpmux2_out = data_from_exmem_in;
        cmpmux::r_data_MemWb2:    cmpmux2_out = data_from_memwb_in;
        cmpmux::i_imm:            cmpmux2_out = i_imm_in;
		default:;
	endcase
	
	case (forwarding_rs2_pass_sel)
		2'b00: rs2passmux_out = reg_data_2_in;
		2'b01: rs2passmux_out = data_from_exmem_in;
		2'b10: rs2passmux_out = data_from_memwb_in;
		default:;
	endcase

end 
endmodule:execute

