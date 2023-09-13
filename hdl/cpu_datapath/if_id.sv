module if_id

import rv32i_types::*;
(
    input clk,
    input rst,
    input stall,
	input flush,
    input logic stall_nop,
	//input from fetch
    input logic [31:0] pc_reg,
    input rv32i_word instr_mem_rdata,
	input logic br_pred_taken_in,
	output logic br_pred_taken_out,
	input rv32i_word br_pred_pc_in,
	output rv32i_word br_pred_pc_out,

	// output to decode
    output rv32i_word instr_mem_rdata_out,
    output logic [31:0] pc_reg_out

);

always_ff @(posedge clk) begin
    if (rst)begin
        pc_reg_out <= rv32i_word'(32'b0);
        instr_mem_rdata_out <= {12'b0, 5'b0, 3'b0,5'b0,7'h13}; // no-op
		br_pred_taken_out <= 1'b0;
		br_pred_pc_out <= 32'b0;
    end
	else if (flush || (flush && stall)) begin
			pc_reg_out <= pc_reg_out;
        	instr_mem_rdata_out <=  {12'b0, 5'b0, 3'b0,5'b0,7'h13}; // no-op
			br_pred_taken_out <= 1'b0;
			br_pred_pc_out <= 32'b0;
	end
    else begin
        if(~stall) begin
            pc_reg_out <=pc_reg; 
            instr_mem_rdata_out <= instr_mem_rdata;
			br_pred_taken_out <= br_pred_taken_in;
			br_pred_pc_out <= br_pred_pc_in;
        end
		/*
        if (stall_nop) begin
			pc_reg_out <= pc_reg_out;
            instr_mem_rdata_out <=  {12'b0, 5'b0, 3'b0,5'b0,7'h13}; // no-op
        end
        */
    end
    
end

endmodule : if_id
