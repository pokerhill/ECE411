module cache_datapath_4 #(
	parameter s_offset = 5,
	parameter s_index = 3,
	parameter s_tag = 32 - s_offset-s_index,
	parameter s_mask = 2**s_offset,
	parameter s_line = 8*s_mask,
	parameter num_sets = 2**s_index
)
(
input clk,
input rst,
input logic [31:0] address,

input logic Dirty1_in,
input logic Dirty2_in,
input logic Dirty3_in,
input logic Dirty4_in,

input logic valid_1_in,
input logic valid_2_in,
input logic valid_3_in,
input logic valid_4_in,

input logic[255:0] mem_wdata256,

input logic Dirty1_load,
input logic Dirty2_load,
input logic Dirty3_load,
input logic Dirty4_load,

input logic LRU_load,

input logic tag_array1_load,
input logic tag_array2_load,
input logic tag_array3_load,
input logic tag_array4_load,

input logic valid_1_load,
input logic valid_2_load,
input logic valid_3_load,
input logic valid_4_load,

input logic [1:0] write_sel_way_1,
input logic [1:0] write_sel_way_2,
input logic [1:0] write_sel_way_3,
input logic [1:0] write_sel_way_4,

input logic read_dirty_array_1,
input logic read_dirty_array_2,
input logic read_dirty_array_3,
input logic read_dirty_array_4,

input logic LRU_read,

input logic read_tag_array_1,
input logic read_tag_array_2,
input logic read_tag_array_3,
input logic read_tag_array_4,

input logic read_data_array_1,
input logic read_data_array_2,
input logic read_data_array_3,
input logic read_data_array_4,

input logic valid_1_in_read,
input logic valid_2_in_read,
input logic valid_3_in_read,
input logic valid_4_in_read,

input logic new_address_sel,

input logic write_read_sel_1,
input logic write_read_sel_2,
input logic write_read_sel_3,
input logic write_read_sel_4,

input logic [1:0] which_tag,
input logic [31:0] mem_byte_enable256,
input logic [2:0] LRU_in,
input logic [1:0] cacheline_sel,
input logic [255:0] cacheline_in,
output logic [255:0] cacheline_out,
output logic [s_tag-1:0]tag_out,

output logic Dirty1_out,
output logic Dirty2_out,
output logic Dirty3_out,
output logic Dirty4_out,

output logic hit1,
output logic hit2,
output logic hit3,
output logic hit4,

output logic [31:0] new_address,
output logic [2:0] LRU_out
);

logic [s_tag-1:0] tag_array1_out;
logic [s_tag-1:0] tag_array2_out;
logic [s_tag-1:0] tag_array3_out;
logic [s_tag-1:0] tag_array4_out;

logic valid_1_out;
logic valid_2_out;
logic valid_3_out;
logic valid_4_out;

array_4_way #(.s_index(s_index), .width(1))
dirty_bit_aray_way_1(
.clk(clk),
.rst(rst),
.read(read_dirty_array_1),
.load(Dirty1_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(Dirty1_in),
.dataout(Dirty1_out)
);

array_4_way #(.s_index(s_index), .width(1))
dirty_bit_aray_way_2(
.clk(clk),
.rst(rst),
.read(read_dirty_array_2),
.load(Dirty2_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(Dirty2_in),
.dataout(Dirty2_out)
);

array_4_way #(.s_index(s_index), .width(1))
dirty_bit_aray_way_3(
.clk(clk),
.rst(rst),
.read(read_dirty_array_3),
.load(Dirty3_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(Dirty3_in),
.dataout(Dirty3_out)
);

array_4_way #(.s_index(s_index), .width(1))
dirty_bit_aray_way_4(
.clk(clk),
.rst(rst),
.read(read_dirty_array_4),
.load(Dirty4_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(Dirty4_in),
.dataout(Dirty4_out)
);

array_4_way #(.s_index(s_index), .width(1))
valid_array_1(
.clk(clk),
.rst(rst),
.read(valid_1_in_read),
.load(valid_1_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(valid_1_in),
.dataout(valid_1_out)
);

array_4_way #(.s_index(s_index), .width(1))
valid_array_2(
.clk(clk),
.rst(rst),
.read(valid_2_in_read),
.load(valid_2_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(valid_2_in),
.dataout(valid_2_out)
);

array_4_way #(.s_index(s_index), .width(1))
valid_array_3(
.clk(clk),
.rst(rst),
.read(valid_3_in_read),
.load(valid_3_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(valid_3_in),
.dataout(valid_3_out)
);

array_4_way #(.s_index(s_index), .width(1))
valid_array_4(
.clk(clk),
.rst(rst),
.read(valid_4_in_read),
.load(valid_4_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(valid_4_in),
.dataout(valid_4_out)
);

array_4_way #(.s_index(s_index), .width(s_tag))
tag_array1(
.clk(clk),
.rst(rst),
.read(read_tag_array_1),
.load(tag_array1_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(address[31:s_offset+s_index]),
.dataout(tag_array1_out)
);

array_4_way #(.s_index(s_index), .width(s_tag))
tag_array2(
.clk(clk),
.rst(rst),
.read(read_tag_array_2),
.load(tag_array2_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(address[31:s_offset+s_index]),
.dataout(tag_array2_out)
);

array_4_way #(.s_index(s_index), .width(s_tag))
tag_array3(
.clk(clk),
.rst(rst),
.read(read_tag_array_3),
.load(tag_array3_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(address[31:s_offset+s_index]),
.dataout(tag_array3_out)
);

array_4_way #(.s_index(s_index), .width(s_tag))
tag_array4(
.clk(clk),
.rst(rst),
.read(read_tag_array_4),
.load(tag_array4_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(address[31:s_offset+s_index]),
.dataout(tag_array4_out)
);

array_4_way #(.s_index(s_index), .width(3))
PLRU_array(
.clk(clk),
.rst(rst),
.read(LRU_read),
.load(LRU_load),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(LRU_in),
.dataout(LRU_out)
);

logic [31:0] write_en_way_1, write_en_way_2, write_en_way_3, write_en_way_4;
logic [255:0] cache_line_data_out_1, cache_line_data_out_2, cache_line_data_out_3, cache_line_data_out_4;
logic [255:0] data_in_1, data_in_2, data_in_3, data_in_4;

data_array_4_way w1(
.clk(clk),
.read(read_data_array_1),
.write_en(write_en_way_1),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(data_in_1),
.dataout(cache_line_data_out_1)
);

data_array_4_way w2(
.clk(clk),
.read(read_data_array_2),
.write_en(write_en_way_2),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(data_in_2),
.dataout(cache_line_data_out_2)
);

data_array_4_way w3(
.clk(clk),
.read(read_data_array_3),
.write_en(write_en_way_3),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(data_in_3),
.dataout(cache_line_data_out_3)
);

data_array_4_way w4(
.clk(clk),
.read(read_data_array_4),
.write_en(write_en_way_4),
.rindex(address[s_offset+s_index-1:s_offset]),
.windex(address[s_offset+s_index-1:s_offset]),
.datain(data_in_4),
.dataout(cache_line_data_out_4)
);

always_comb begin
	case(write_read_sel_1)
	1'b0: data_in_1= cacheline_in;
	1'b1: data_in_1= mem_wdata256;
	endcase
	case(write_read_sel_2)
	1'b0: data_in_2= cacheline_in;
	1'b1: data_in_2= mem_wdata256;
	endcase
	case(write_read_sel_3)
	1'b0: data_in_3= cacheline_in;
	1'b1: data_in_3= mem_wdata256;
	endcase
	case(write_read_sel_4)
	1'b0: data_in_4= cacheline_in;
	1'b1: data_in_4= mem_wdata256;
	endcase
	case (new_address_sel)
	1'b0: new_address = {address[31:s_offset],5'b0};
	1'b1: new_address = {tag_out, address[s_offset+s_index-1:s_offset],5'b0};
	endcase
	case (which_tag)
	2'b0: tag_out = tag_array1_out;
	2'b1: tag_out = tag_array2_out;
	2'b10: tag_out = tag_array3_out;
	2'b11: tag_out = tag_array4_out;
	endcase

	case (cacheline_sel)
	2'b0: cacheline_out = cache_line_data_out_1;
	2'b1: cacheline_out = cache_line_data_out_2;
	2'b10: cacheline_out = cache_line_data_out_3;
	2'b11: cacheline_out = cache_line_data_out_4;
	endcase

	unique case(write_sel_way_1)
	2'b10: write_en_way_1 = mem_byte_enable256;
	2'b01: write_en_way_1 = {32{1'b1}};
	default: write_en_way_1 = {32{1'b0}};
	endcase

	unique case(write_sel_way_2)
	2'b10: write_en_way_2 = mem_byte_enable256;
	2'b01: write_en_way_2 = {32{1'b1}};
	default: write_en_way_2 = {32{1'b0}};
	endcase

	unique case(write_sel_way_3)
	2'b10: write_en_way_3 = mem_byte_enable256;
	2'b01: write_en_way_3 = {32{1'b1}};
	default: write_en_way_3 = {32{1'b0}};
	endcase

	unique case(write_sel_way_4)
	2'b10: write_en_way_4 = mem_byte_enable256;
	2'b01: write_en_way_4 = {32{1'b1}};
	default: write_en_way_4 = {32{1'b0}};
	endcase

unique case (read_tag_array_1)
		1'b1: begin
			if ((address[31:s_offset+s_index] == tag_array1_out) && valid_1_out) begin
			 hit1 = 1'b1;
end
			else 
			hit1 = 1'b0;
end
	default: hit1 = 1'b0;
endcase

unique case (read_tag_array_2)
		1'b1: begin
			if ((address[31:s_offset+s_index] == tag_array2_out) && valid_2_out) begin
			 hit2 = 1'b1;
end
			else 
			hit2 = 1'b0;
end
	default: hit2 = 1'b0;
endcase

unique case (read_tag_array_3)
		1'b1: begin
			if ((address[31:s_offset+s_index] == tag_array3_out) && valid_3_out) begin
			 hit3 = 1'b1;
end
			else 
			hit3 = 1'b0;
end
	default: hit3 = 1'b0;
endcase

unique case (read_tag_array_4)
		1'b1: begin
			if ((address[31:s_offset+s_index] == tag_array4_out) && valid_4_out) begin
			 hit4 = 1'b1;
end
			else 
			hit4 = 1'b0;
end
	default: hit4 = 1'b0;
endcase

end

endmodule: cache_datapath_4