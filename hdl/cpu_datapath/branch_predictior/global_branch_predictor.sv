module global_br_pred
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

//logic [9:0] address_part;
//assign address_part = pc_in[9:0]; // can change length if needed later

logic [9:0] ghr_data, ghr_new;

enum logic [2:0] {
	STRONGLY_TAKEN, WEAKLY_TAKEN, WEAKLY_NOT_TAKEN, STRONGLY_NOT_TAKEN
} pattern_states [2**10-1:0], updated_pstate;

logic [9:0] pht_index;


always_comb begin
	// default
	if (rst) begin
		flush = 1'b0;
		ghr_new = 10'b0;
	//	stall_nop_ifid = 1'b0;
	//	stall_pc = 1'b0;
	end

/*
	if (stall) begin
		flush = flush;
		stall_nop_ifid = stall_nop_ifid;
		stall_pc = stall_pc;
	end
*/
//	else begin	
//			flush = 1'b0;
//			stall_nop_ifid = 1'b0;
//			stall_pc = 1'b0;
		if (~read) begin
			if (~stall) begin
				flush = 1'b0;
	//			stall_pc = 1'b0;
			end
		end	
		if (read) begin
			if (~stall) begin
				pht_index = pc_in[9:0] ^ ghr_data;
				case (pattern_states[pht_index])
					STRONGLY_TAKEN: begin 
						flush = 1'b1;
	//					stall_pc = 1'b1;
				//		stall_nop_ifid = 1'b1;
					end
					WEAKLY_TAKEN: begin
						flush = 1'b1;
	//					stall_pc = 1'b1;
				//		stall_nop_ifid = 1'b1;
					end
					WEAKLY_NOT_TAKEN: flush = 1'b0;
					STRONGLY_NOT_TAKEN: flush = 1'b0;
				endcase
			end
			/*
			if (flush) begin
				stall_nop_ifid = 1'b0;
				//stall_pc = 1'b1;
			end
			*/
		end

		if (load) begin
			flush = 1'b0;
			/*
			stall_nop_ifid = 1'b0;
			stall_pc = 1'b0;
			*/
			pht_index = pc_mem_stage[9:0] ^ ghr_data;
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
			
			// update the ghr at the end
			ghr_new = ghr_data << 1 | taken;
		end
//	end
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
		for (int i = 0; i < 2**10; i++)
			pattern_states[i] <= WEAKLY_NOT_TAKEN;
		ghr_data <= 10'b0;
		//flush <= '0;
	end
	else if (stall) begin
		ghr_data <= ghr_data;
		pattern_states[pht_index] <= pattern_states[pht_index];
	end
	else if (load) begin
		ghr_data <= ghr_new;
		pattern_states[pht_index] <= updated_pstate;		
	end
	// NEED TO ADD SMTH ABT STALLS?
end





// IGNORE THIS SECTION
/*
logic [9:0] ghr_out;
logic delayed_load;
logic delayed_read;


// global history register
global_hist_reg #(.reg_length(10))
GHR (
	.clk(clk),
	.rst(rst),
	.read_in(read),
	.load_in(load),
	.history_in(taken),
	.read_out(delayed_read),
	.load_out(delayed_load),
	.history_out(ghr_out),
)

logic pht_index;
assign pht_index = address_part ^ ghr_out;

// pattern history table
pred_hist_counter #(.s_index(8))
GLOBAL_PHT (
	.clk(clk),
	.rst(rst),
	.read(delayed_read),
	.load(delayed_load),
	.index(pht_index),
	.history_in(),
	.flush(flush),
);
*/


endmodule : global_br_pred
