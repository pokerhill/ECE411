module static_nt_predictor
import rv32i_types::*;
(
    input logic cmp_out,
    input rv32i_opcode opcode,
	input logic br_pred_taken, // used to get correctness
	output logic mispredicted, // only needed for when br taken when not supposed to
    output logic flush,
	//output logic update_hist_table,
	output logic update_br_pred_taken
);

always_comb begin
	//update_hist_table = 1'b0;
	// flushing logic
    if ( opcode == op_jal || opcode == op_jalr) begin
        flush =  1'b1;
    end
	else if (opcode == op_br) begin
		if (cmp_out == 1'b1) begin
			if (br_pred_taken) begin
				flush = 1'b0;
				update_br_pred_taken = 1'b1;
				//update_hist_table = 1'b1;
				mispredicted = 1'b0;
			end
			else begin // br not taken but supposed to be taken
				flush = 1'b1;
				update_br_pred_taken = 1'b1;
				//update_hist_table = 1'b1;
				mispredicted = 1'b0;
			end
		end
		else if (cmp_out == 1'b0) begin
			if (br_pred_taken) begin // br taken but supposed to NOT be taken
				flush = 1'b1;
				update_br_pred_taken = 1'b0;
				//update_hist_table = 1'b1;
				mispredicted = 1'b1;
			end
			else begin
				flush = 1'b0;
				update_br_pred_taken = 1'b0;
				//update_hist_table = 1'b1;
				mispredicted = 1'b0;
			end
		end
	end
    else begin
        flush = 1'b0;
		//update_hist_table = 1'b0;
		mispredicted = 1'b0;
		update_br_pred_taken = 1'b0;
    end

end
endmodule : static_nt_predictor
