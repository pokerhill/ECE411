module arbiter
import rv32i_types::*;
(
	input clk,
	input rst,

	// inputs from I-cache -- READ ONLY
	input logic i_cache_read,
	input rv32i_word i_cache_address,

	// inputs from D-cache -- READ AND WRITE
	input logic d_cache_read,
	input logic d_cache_write,
	input rv32i_word d_cache_address,
	input logic [255:0] d_cache_wdata,

	// inputs from next level memory
	input logic next_level_arb_mem_resp,
	input logic [255:0] next_level_arb_rdata,
	

	// outputs to I-cache
	output logic i_cache_mem_resp,
	output logic [255:0] i_cache_rdata,

	// outputs to  D-cache
	output logic d_cache_mem_resp,
	output logic [255:0] d_cache_rdata,

	// outputs to next level memory
	output rv32i_word arb_next_level_address,
	output logic arb_next_level_read,
	output logic arb_next_level_write,
	output logic [255:0] arb_next_level_wdata

);

// define states
enum logic [1:0]  {
	IDLE, I_CACHE_ALLOW, D_CACHE_ALLOW
} state, next_state;

// function to set defaults
function void set_defaults();
	i_cache_mem_resp = 1'b0;
	i_cache_rdata = 256'b0;
	d_cache_mem_resp = 1'b0;
	d_cache_rdata = 256'b0;
	arb_next_level_address = 32'b0;
	arb_next_level_read = 1'b0;
	arb_next_level_write = 1'b0;
	arb_next_level_wdata = 256'b0;
endfunction

// define local variables
//logic arbiter_ready;
logic d_cache_req;
assign d_cache_req = d_cache_read | d_cache_write;
logic i_cache_req;
assign i_cache_req = i_cache_read;

// state actions
always_comb
begin : state_actions
	set_defaults();
	case (state) 
		IDLE: begin
			// only send information back if this is set high from the ALLOW
				// states
		/*
			if (arbiter_ready) begin
				if (d_cache_read) begin
					d_cache_rdata = next_level_arb_rdata;
					d_cache_mem_resp = 1'b1;
				end
				else if (d_cache_write) begin
					d_cache_mem_resp = 1'b1;
				end 
				else if (i_cache_read) begin
					i_cache_rdata = next_level_arb_rdata;
					i_cache_mem_resp = 1'b1;
					arbiter_ready = 1'b0;
				end
			end
		*/
		end

		D_CACHE_ALLOW: begin
			arb_next_level_address = d_cache_address;
			if (d_cache_read) begin
				arb_next_level_read = 1'b1;
				arb_next_level_write = 1'b0;
			end
			else if (d_cache_write) begin
				arb_next_level_write = 1'b1;
				arb_next_level_read = 1'b0;
				arb_next_level_wdata = d_cache_wdata;
			end

			if (next_level_arb_mem_resp) begin
				d_cache_mem_resp = 1'b1;
				d_cache_rdata = next_level_arb_rdata;
			end
	//		arbiter_ready = 1'b1;
		end

		I_CACHE_ALLOW: begin
			arb_next_level_address = i_cache_address;
			arb_next_level_read = 1'b1;
			arb_next_level_write = 1'b0;
			if (next_level_arb_mem_resp) begin
				i_cache_mem_resp = 1'b1;
				i_cache_rdata = next_level_arb_rdata;
			end
	//		arbiter_ready = 1'b1;
		end
	endcase

end


// next state logic 
always_comb
begin : next_stage_logic
	case (state) 
		IDLE: begin
			if (d_cache_req == 1)
				next_state = D_CACHE_ALLOW;
			else if (i_cache_req == 1 && d_cache_req == 0)
				next_state = I_CACHE_ALLOW;
			else
				next_state = IDLE;
		end

		D_CACHE_ALLOW: begin
			if (~next_level_arb_mem_resp) 
				next_state = D_CACHE_ALLOW;
			else if (next_level_arb_mem_resp)
				next_state = IDLE;
		end

		I_CACHE_ALLOW: begin
			if (~next_level_arb_mem_resp)
				next_state = I_CACHE_ALLOW;
			else if (next_level_arb_mem_resp)
				next_state = IDLE;
		end
	endcase

end


// always ff assignments
always_ff @(posedge clk)
begin : next_state_assignment
	if (rst)
		state <= IDLE;
	else
		state <= next_state;
end



endmodule : arbiter
