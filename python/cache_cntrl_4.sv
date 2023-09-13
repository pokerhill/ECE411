module cache_cntrl_4(
	input clk,
	input rst,
	input mem_resp_cache,
	input logic read,
	input logic write,

	input logic hit1,
	input logic hit2,
	input logic hit3,
	input logic hit4,
	
	input logic Dirty1_out,
	input logic Dirty2_out,
	input logic Dirty3_out,
	input logic Dirty4_out,
	
	input logic [2:0] LRU_out,
	output logic [1:0] which_tag,
	output logic new_address_sel,
	
	output logic valid_1_in,
	output logic valid_2_in,
	output logic valid_3_in,
	output logic valid_4_in,
	
	output logic [2:0] LRU_in,

	output logic Dirty1_load,
	output logic Dirty2_load,
	output logic Dirty3_load,
	output logic Dirty4_load,
	
	output logic LRU_load,
	output logic LRU_read,

	output logic tag_array1_load,
	output logic tag_array2_load,
	output logic tag_array3_load,
	output logic tag_array4_load,
	
	output logic read_data_array_1,
	output logic read_data_array_2,
	output logic read_data_array_3,
	output logic read_data_array_4,
	
	output logic valid_1_load,
	output logic valid_2_load,
	output logic valid_3_load,
	output logic valid_4_load,
	
	output logic [1:0] write_sel_way_1,
	output logic [1:0] write_sel_way_2,
	output logic [1:0] write_sel_way_3,
	output logic [1:0] write_sel_way_4,
	
	output logic write_read_sel_1,
	output logic write_read_sel_2,
	output logic write_read_sel_3,
	output logic write_read_sel_4,
	
	output logic read_dirty_array_1,
	output logic read_dirty_array_2,
	output logic read_dirty_array_3,
	output logic read_dirty_array_4,
	
	output logic read_tag_array_1,
	output logic read_tag_array_2,
	output logic read_tag_array_3,
	output logic read_tag_array_4,
	
	output logic valid_1_in_read,
	output logic valid_2_in_read,
	output logic valid_3_in_read,
	output logic valid_4_in_read,
	
	output logic [1:0] cacheline_sel,

	output logic Dirty1_in,
	output logic Dirty2_in,
	output logic Dirty3_in,
	output logic Dirty4_in,
	

	output logic pmem_read,
	output logic pmem_write,
	output logic done
);

logic [1:0] replace_which_way;
logic hit_check;
logic dirty;
logic[2:0] temp_PLRU;

function void load_PLRU(logic h1, logic h2, logic h3, logic h4);
	LRU_in = LRU_out;
	if (h1) begin
		LRU_in[1] = 1'b0;
		LRU_in[0] = 1'b0;
	end

	if (h2) begin
		LRU_in[1] = 1'b0;
		LRU_in[0] = 1'b1;
	end

	if (h3) begin
		LRU_in[1] = 1'b1;
		LRU_in[2] = 1'b0;
	end

	if (h4) begin
		LRU_in[1] = 1'b1;
		LRU_in[2] = 1'b1;
	end

	endfunction
function void which_dirty( logic [2:0] replace,  logic d1, logic d2, logic d3, logic d4);
	case (replace)
	2'b0: dirty = d1;
	2'b1: dirty = d2;
	2'b10: dirty = d3;
	2'b11: dirty = d4;
	endcase
endfunction

function void set_defaults();
	cacheline_sel = 2'b0;

	valid_1_in = 1'b0;
	valid_2_in = 1'b0;
	valid_3_in = 1'b0;
	valid_4_in = 1'b0;
	
	LRU_in = 3'b0;
	LRU_load = 1'b0;
	LRU_read = 1'b1;

	Dirty1_load = 1'b0;
	Dirty2_load = 1'b0;
	Dirty3_load = 1'b0;
	Dirty4_load = 1'b0;

	tag_array1_load = 1'b0;
	tag_array2_load = 1'b0;
	tag_array3_load = 1'b0;
	tag_array4_load = 1'b0;

	valid_1_load = 1'b0;
	valid_2_load = 1'b0;
	valid_3_load = 1'b0;
	valid_4_load = 1'b0;

	write_sel_way_1 = 2'b00;
	write_sel_way_2 = 2'b00;
	write_sel_way_3 = 2'b00;
	write_sel_way_4 = 2'b00;

	read_dirty_array_1 = 1'b1;
	read_dirty_array_2 = 1'b1;
	read_dirty_array_3 = 1'b1;
	read_dirty_array_4 = 1'b1;

	read_tag_array_1 = 1'b1;
	read_tag_array_2 = 1'b1;
	read_tag_array_3 = 1'b1;
	read_tag_array_4 = 1'b1;

	read_data_array_1 = 1'b1;
	read_data_array_2 = 1'b1;
	read_data_array_3 = 1'b1;
	read_data_array_4 = 1'b1;

	valid_1_in_read = 1'b1;
	valid_2_in_read = 1'b1;
	valid_3_in_read = 1'b1;
	valid_4_in_read = 1'b1;

	pmem_read = 1'b0;
	pmem_write=1'b0;
	new_address_sel=1'b0;
	done=1'b0;

	write_read_sel_1 = 1'b0;
	write_read_sel_2 = 1'b0;
	write_read_sel_3 = 1'b0;
	write_read_sel_4 = 1'b0;
endfunction

function void which_replace( logic [2:0] PLRU);
	temp_PLRU = ~PLRU;
	if (temp_PLRU[1] == 1'b0) begin
		if (temp_PLRU[0] == 1'b0) begin
			replace_which_way = 2'b0;
			which_tag = 2'b0;
		end
	end
	if (temp_PLRU[1] == 1'b0) begin
		if (temp_PLRU[0] == 1'b1) begin
			replace_which_way = 2'b1;
			which_tag = 2'b1;
		end
	end
	if (temp_PLRU[1] == 1'b1) begin
		if (temp_PLRU[2] == 1'b0) begin
			replace_which_way = 2'b10;
			which_tag = 2'b10;
		end
	end
	if (temp_PLRU[1] == 1'b1) begin
		if (temp_PLRU[2] == 1'b1) begin
			replace_which_way = 2'b11;
			which_tag = 2'b11;
		end
	end
endfunction

assign hit_check = (hit1||hit2||hit3||hit4);
enum int unsigned {
	hit,
	miss_clean, 
	miss_dirty
} curr_state, next_state;

always_comb begin
	set_defaults();
	which_replace(LRU_out);
	which_dirty(replace_which_way, Dirty1_out, Dirty2_out, Dirty3_out, Dirty4_out);
	case(curr_state)
		hit:begin
		if(!(read||write))begin
			set_defaults();
		end
		else begin
			if(~hit_check) begin
				LRU_read = 1'b1;
			end
			else begin
				LRU_load=1'b1;
				load_PLRU(hit1, hit2, hit3, hit4);
				if(read)begin
					if(hit1) begin
						 cacheline_sel = 2'b0;
					end
					else if(hit2) begin
						 cacheline_sel = 2'b1;
					end
					else if(hit3) begin
						 cacheline_sel = 2'b10;
					end
					else if(hit4) begin
						 cacheline_sel = 2'b11;
					end
				end
				else if(write)begin
					if(hit1) begin
						cacheline_sel = 2'b0;
						Dirty1_in = 1'b1;
						Dirty1_load = 1'b1;
						write_read_sel_1 = 1'b1;
						write_sel_way_1 = 2'b10;
					end
					else if(hit2) begin
						cacheline_sel = 2'b1;
						Dirty2_in = 1'b1;
						Dirty2_load = 1'b1;
						write_read_sel_2 = 1'b1;
						write_sel_way_2 = 2'b10;
					end
					else if(hit3) begin
						cacheline_sel = 2'b10;
						Dirty3_in = 1'b1;
						Dirty3_load = 1'b1;
						write_read_sel_3 = 1'b1;
						write_sel_way_3 = 2'b10;
					end
					else if(hit4) begin
						cacheline_sel = 2'b11;
						Dirty4_in = 1'b1;
						Dirty4_load = 1'b1;
						write_read_sel_4 = 1'b1;
						write_sel_way_4 = 2'b10;
					end
				end
			done = 1'b1;
		end
end
end
	miss_clean:begin
		pmem_read = 1'b1;
		if(read) begin
			cacheline_sel = replace_which_way;
			case(replace_which_way)
			3'b0: begin
				tag_array1_load = 1'b1;
				valid_1_load = 1'b1;
				valid_1_in = 1'b1;
				write_sel_way_1 = 2'b01;
			end
			3'b1: begin
				tag_array2_load = 1'b1;
				valid_2_load = 1'b1;
				valid_2_in = 1'b1;
				write_sel_way_2 = 2'b01;
			end
			3'b10: begin
				tag_array3_load = 1'b1;
				valid_3_load = 1'b1;
				valid_3_in = 1'b1;
				write_sel_way_3 = 2'b01;
			end
			3'b11: begin
				tag_array4_load = 1'b1;
				valid_4_load = 1'b1;
				valid_4_in = 1'b1;
				write_sel_way_4 = 2'b01;
			end
		endcase
	end
	else if (write) begin
		cacheline_sel = replace_which_way;
		case(replace_which_way)
			3'b0: begin
				tag_array1_load = 1'b1;
				valid_1_load = 1'b1;
				valid_1_in = 1'b1;
				write_sel_way_1 = 2'b01;
			end
			3'b1: begin
				tag_array2_load = 1'b1;
				valid_2_load = 1'b1;
				valid_2_in = 1'b1;
				write_sel_way_2 = 2'b01;
			end
			3'b10: begin
				tag_array3_load = 1'b1;
				valid_3_load = 1'b1;
				valid_3_in = 1'b1;
				write_sel_way_3 = 2'b01;
			end
			3'b11: begin
				tag_array4_load = 1'b1;
				valid_4_load = 1'b1;
				valid_4_in = 1'b1;
				write_sel_way_4 = 2'b01;
			end
		endcase
	end
end
	miss_dirty:begin
		pmem_write = 1'b1;
		new_address_sel = 1'b1;
		cacheline_sel=replace_which_way;
		case (replace_which_way)
			2'b0: begin
			Dirty1_in = 1'b0;
			Dirty1_load = 1'b1;
		end
			2'b1: begin
			Dirty2_in = 1'b0;
			Dirty2_load = 1'b1;
		end
			2'b10: begin
			Dirty3_in = 1'b0;
			Dirty3_load = 1'b1;
		end
			2'b11: begin
			Dirty4_in = 1'b0;
			Dirty4_load = 1'b1;
		end
	endcase
end
endcase
end
always_comb begin
	next_state = curr_state;
case(curr_state)
hit:begin
	if(read||write) begin
		if(hit_check) begin
		next_state = hit;
	end
	else if(~hit_check && ~dirty)
		next_state = miss_clean;
	else if(~hit_check && dirty)
		next_state=miss_dirty;
	end
end
miss_dirty:begin
	if(~mem_resp_cache)
		next_state = miss_dirty;
	else
		next_state = miss_clean;
	end
miss_clean:begin
	if(~mem_resp_cache)
		next_state = miss_clean;
	else
	next_state = hit;
end
endcase
end

always_ff @ (posedge clk) begin
	if(rst)begin
		curr_state<=hit;
	end
	else begin
		curr_state<= next_state;
	end
end
endmodule : cache_cntrl_4