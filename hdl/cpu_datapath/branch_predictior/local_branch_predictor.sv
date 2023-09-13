module local_br_pred
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

	//output logic stall_pc,
	//output logic stall_nop_ifid,
	output logic flush

);

//local variables
logic [7:0] lhr_index;
//assign lhr_index = pc_in[7:0];

// local history registers
logic [11:0] local_hist_registers [7:0];
logic [11:0] new_local_hist_reg_val;

// pattern history table 
logic [11:0] pht_index;
enum logic [2:0] {
	STRONGLY_TAKEN, WEAKLY_TAKEN, WEAKLY_NOT_TAKEN, STRONGLY_NOT_TAKEN
} pattern_states[2**12-1:0], updated_pstate;


always_comb begin
	if (rst) begin
		flush = 1'b0;
		new_local_hist_reg_val = 12'b0;
		//stall_pc = 1'b0;
		//stall_nop_ifid = 1'b0;
	end
/*
	else if (stall) begin
		flush = flush;
		stall_nop_ifid = stall_nop_ifid;
		stall_pc = stall_pc;
	end
*/
	if (~read) begin
		if (~stall) begin
			flush = 1'b0;
			//stall_pc = 1'b0;
		end
	end
	

	if (read) begin
		lhr_index = pc_in[7:0];

		//flush = 1'b0;
		//stall_nop_ifid = 1'b0;
		//stall_pc = 1'b0;
		// lookup lhr table
		pht_index = local_hist_registers[lhr_index];

		// lookup pht table
		case (pattern_states[pht_index])
			STRONGLY_TAKEN: begin
				flush = 1'b1;
			//	stall_pc = 1'b1;
			end
			WEAKLY_TAKEN: begin
				flush = 1'b1;
			//	stall_pc = 1'b1;
			end
			WEAKLY_NOT_TAKEN: flush = 1'b0;
			STRONGLY_NOT_TAKEN: flush = 1'b0;
		endcase
		/*
		if (flush) begin
			//stall_nop_ifid = 1'b1;
			stall_pc = 1'b1;
		end	
		*/
	end

	if (load) begin
		/*
		flush = 1'b0;
		stall_nop_ifid = 1'b0;
		stall_pc = 1'b0;
		*/
	   	lhr_index = pc_mem_stage[7:0];
		pht_index = local_hist_registers[lhr_index];

		// update pattern history table
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

		// update local history register
		new_local_hist_reg_val = local_hist_registers[lhr_index] << 1 | taken;

	end
	/*
	else begin
		flush = 1'b0;
		stall_pc = 1'b0;
		stall_nop_ifid = 1'b0;
	end
	*/

end


always_ff @(posedge clk) begin
	if (rst) begin
		for (int i = 0; i < 2**12; i++) 
			pattern_states[i] <= WEAKLY_NOT_TAKEN;
		for (int j = 0; j < 2**8; j++) 
			local_hist_registers[j] <= 12'b0;
	end
	
	else if (stall) begin
		local_hist_registers[lhr_index] <= local_hist_registers[lhr_index];
		pattern_states[pht_index] <= pattern_states[pht_index]; 
	end

	else if (load) begin
		local_hist_registers[lhr_index] <= new_local_hist_reg_val;
		pattern_states[pht_index] <= updated_pstate; 
	end
end



/*
pred_hist_array #(.s_index(8), .width(5))
LOCAL_BHT (
	.clk(clk),
	.rst(rst),
	.read(read),
	.load_in(load),
	.rindex(array_index),
	.windex(array_index),
	.data_in(br_taken),
	.load_out(load_pht), // used to help delay the load signal by one clock cycle for PHT
	.data_out(history_found)
);

// pattern history table
pred_hist_counter (.s_index(8)) 
LOCAL_PHT (
	.clk(clk),
	.rst(rst),
	.read(read_pht),
	.load(load_pht),
	.index(array_index),
	.history_in(history_found),
	.flush(flush),
);
*/

endmodule : local_br_pred
