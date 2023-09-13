module cache_4_way #(
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

input logic [31:0] mem_address,
output logic[31:0] mem_rdata,
input logic [31:0] mem_wdata,
input logic mem_read,
input logic mem_write,
input logic [3:0] mem_byte_enable,
output logic mem_resp,

output logic [31:0] pmem_address,
input logic [255:0] pmem_rdata,
output logic [255:0] pmem_wdata,
output logic pmem_read,
output logic pmem_write,
input logic pmem_resp
);
logic mem_resp_cache;
assign mem_resp_cache = pmem_resp;
logic write;
assign write = mem_write;
logic read;
assign read = mem_read;
logic [31:0] address;
assign address = mem_address;
logic [31:0]new_address;
assign pmem_address = new_address;
logic [1:0] which_tag;
logic Dirty1_in;
logic Dirty2_in;
logic Dirty3_in;
logic Dirty4_in;

logic valid_1_in;
logic valid_2_in;
logic valid_3_in;
logic valid_4_in;

logic Dirty1_load;
logic Dirty2_load;
logic Dirty3_load;
logic Dirty4_load;

logic [1:0] cacheline_sel;
logic LRU_load;
logic tag_array1_load;
logic tag_array2_load;
logic tag_array3_load;
logic tag_array4_load;

logic valid_1_load;
logic valid_2_load;
logic valid_3_load;
logic valid_4_load;

logic [1:0] write_sel_way_1, write_sel_way_2, write_sel_way_3, write_sel_way_4;
logic [2:0] LRU_out;

logic read_dirty_array_1;
logic read_dirty_array_2;
logic read_dirty_array_3;
logic read_dirty_array_4;

logic LRU_read;
logic read_tag_array_1;
logic read_tag_array_2;
logic read_tag_array_3;
logic read_tag_array_4;

logic read_data_array_1;
logic read_data_array_2;
logic read_data_array_3;
logic read_data_array_4;

logic valid_1_in_read;
logic valid_2_in_read;
logic valid_3_in_read;
logic valid_4_in_read;

logic new_address_sel;

logic [2:0] LRU_in;
logic [255:0] cacheline_in;
assign cacheline_in = pmem_rdata;
logic [255:0] cacheline_out;
logic [255:0] mem_rdata256;
logic [255:0] mem_wdata256;
assign mem_rdata256 = cacheline_out;
assign pmem_wdata = cacheline_out;
logic [s_tag-1:0] tag_out;

logic Dirty1_out;
logic Dirty2_out;
logic Dirty3_out;
logic Dirty4_out;

logic hit1;
logic hit2;
logic hit3;
logic hit4;

logic [31:0] mem_byte_enable256;
logic done;
logic write_read_sel_1;
logic write_read_sel_2;
logic write_read_sel_3;
logic write_read_sel_4;

assign mem_resp = done;
cache_cntrl_4 control
(.*
);
cache_datapath_4 datapath
(.*
);
bus_adapter_4_way bus_adapter
(.*
);
endmodule: cache_4_way