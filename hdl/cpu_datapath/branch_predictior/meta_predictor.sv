module meta_pred
import rv32i_types::*;
(
	input clk,
	input rst,

	input logic read,
	input logic load,
	input logic stall,
	input logic taken,
	input rv32i_word pc_in,
	input rv32i_word pc_mem_stage,

	// LOCAL IS 1'b1 & GLOBAL IS 1'b0;
	output logic br_pred_sel
);


logic [9:0] pht_index;


// NOTE: TAKEN WILL BE LOCAL, NOT_TAKEN WILL BE GLOBAL
enum int unsigned {
	STRONGLY_TAKEN, WEAKLY_TAKEN, WEAKLY_NOT_TAKEN, STRONGLY_NOT_TAKEN
} pattern_states [2**10-1:0], updated_pstate;


always_comb begin
	if (rst) begin
		br_pred_sel = 1'b0;
	end

	/*
	else if (stall) begin
		br_pred_sel = br_pred_sel;
	end
	*/
    if (~read) begin
		if (~stall) begin
			br_pred_sel = 1'b0;
		end
	end

	else if (read) begin
		pht_index = pc_in[9:0];
		br_pred_sel = 1'b0;
		case (pattern_states[pht_index])
			STRONGLY_TAKEN: br_pred_sel = 1'b1;
			WEAKLY_TAKEN: br_pred_sel = 1'b1;
			WEAKLY_NOT_TAKEN: br_pred_sel = 1'b0;
			STRONGLY_NOT_TAKEN: br_pred_sel = 1'b0;
		endcase
	end

	else if (load) begin
		pht_index = pc_mem_stage[9:0];
		br_pred_sel = 1'b0;
		case (pattern_states[pht_index])
			STRONGLY_TAKEN: begin
				if (taken)
					updated_pstate = STRONGLY_TAKEN;
				else
					updated_pstate = WEAKLY_TAKEN;
			end
			WEAKLY_TAKEN: begin
				if (taken)
					updated_pstate = STRONGLY_TAKEN;
				else
					updated_pstate = WEAKLY_NOT_TAKEN;
			end
			WEAKLY_NOT_TAKEN: begin
				if (taken)
					updated_pstate = WEAKLY_TAKEN;
				else
					updated_pstate = STRONGLY_NOT_TAKEN;
			end
			STRONGLY_NOT_TAKEN: begin
				if (taken)
					updated_pstate = WEAKLY_TAKEN;
				else
					updated_pstate = STRONGLY_NOT_TAKEN;
			end
		endcase	
	end
end

always_ff @(posedge clk) begin
	if (rst) begin
		for (int i = 0; i < 2**10; i++)
			pattern_states[i] <= WEAKLY_NOT_TAKEN;
	end
	else if (stall) begin
		pattern_states[pht_index] <= pattern_states[pht_index];
	end
	else if (load) begin
		pattern_states[pht_index] <= updated_pstate;
	end
end


endmodule : meta_pred
