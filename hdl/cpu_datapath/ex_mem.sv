module ex_mem
import rv32i_types::*;

( //need to fix
    input clk,
    input rst,

    input rv32i_word reg_pc_in,
    //input rv32i_word reg_1_in,
    input rv32i_word reg_2_in,
    input rv32i_reg reg_dest_in,
    input logic cmp_val_in,
    input rv32i_word u_imm_in,
    input rv32i_word alu_val_in,
    input rv32i_control_word cntrl_word_in,
    input logic [2:0] funct3_in,
	input logic br_pred_taken_in,
    input stall,
	input flush,
    input rv32i_reg rs2_id_in,

    output rv32i_reg reg_dest_out,
    //output rv32i_word reg_1_out,
    output rv32i_word reg_2_out,
    output rv32i_word u_imm_out,
    output rv32i_word reg_pc_out,
    output logic cmp_val_out,
    output rv32i_word alu_val_out,
    output rv32i_control_word cntrl_word_out,
    output logic [2:0] funct3_out,
	output logic br_pred_taken_out,
    output rv32i_reg rs2_id_out,
	input rv32i_opcode opcode_in,
	output rv32i_opcode opcode_out
);

//assign opcode_out = opcode_in;

always_ff @(posedge clk) begin
    if (rst)begin
        reg_pc_out <= rv32i_word'(32'b0);
        u_imm_out <=rv32i_word'(32'b0);
        //reg_1_out <= rv32i_word'(32'b0);
        reg_2_out <=rv32i_word'(32'b0);
        reg_dest_out <= rv32i_reg'(5'b0); //may need to change later cuase this is "reg0"
        cmp_val_out <= 1'b0;
        alu_val_out <= rv32i_word'(32'b0);
        //cntrl_word_out <= rv32i_control_word'(1'b0); //fix when size of control word is known
		cntrl_word_out <= rv32i_control_word'({3'b0,3'b0,1'b0,2'b0, 3'b0, 4'b0, 2'b0, 1'b0, 1'b0, 1'b1, 7'h13});
        funct3_out <= 3'b0;
		opcode_out <= opcode_in;
        rs2_id_out <= rv32i_reg'(1'b0);
		br_pred_taken_out <= 1'b0;
    end
	else if (flush) begin
		if (stall)
		; //while stalling keep branch instruction
		else begin
		//opcode_out <= rv32i_opcode'(7'h13); //if not stalling replace no-op to prevent double branch.
		//cntrl_word_out <= rv32i_control_word'(1'b0);
			reg_pc_out <= rv32i_word'(32'b0);
			u_imm_out <= rv32i_word'(32'b0);
			reg_2_out <= rv32i_word'(1'b0);
			reg_dest_out <= rv32i_reg'(1'b0);
			cmp_val_out <= 1'b0;
			alu_val_out <= rv32i_word'(32'b0);
			cntrl_word_out <= rv32i_control_word'({3'b0,3'b0,1'b0,2'b0, 3'b0, 4'b0, 2'b0, 1'b0, 1'b0, 1'b1, 7'h13});
			funct3_out <= 3'b0;
			opcode_out <= rv32i_opcode'(7'h13);
			rs2_id_out <= rv32i_reg'(1'b0);
			br_pred_taken_out <= 1'b0;
		end
	end
    else begin
        if (~stall) begin
            reg_pc_out <=reg_pc_in; 
            u_imm_out <= u_imm_in;
            //reg_1_out <= reg_1_in;
            reg_2_out <=reg_2_in;
            reg_dest_out <= reg_dest_in;
            cmp_val_out <= cmp_val_in;
            alu_val_out <= alu_val_in;
            cntrl_word_out <= cntrl_word_in;
            funct3_out <= funct3_in;
		    opcode_out <= opcode_in;
            rs2_id_out <= rs2_id_in;
			br_pred_taken_out <= br_pred_taken_in;
        end

    end

end
endmodule : ex_mem


