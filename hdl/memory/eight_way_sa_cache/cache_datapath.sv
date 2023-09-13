/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */



module modular_cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
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
    input logic Dirty5_in,
    input logic Dirty6_in,
    input logic Dirty7_in,
    input logic Dirty8_in,

    input logic valid_1_in,
    input logic valid_2_in,
    input logic valid_3_in,
    input logic valid_4_in,
    input logic valid_5_in,
    input logic valid_6_in,
    input logic valid_7_in,
    input logic valid_8_in,

    input logic [255:0] mem_wdata256,

    input logic Dirty1_load,
    input logic Dirty2_load,
    input logic Dirty3_load,
    input logic Dirty4_load,
    input logic Dirty5_load,
    input logic Dirty6_load,
    input logic Dirty7_load,
    input logic Dirty8_load,

    input logic LRU_load,

    input logic tag_array1_load,
    input logic tag_array2_load,
    input logic tag_array3_load,
    input logic tag_array4_load,
    input logic tag_array5_load,
    input logic tag_array6_load,
    input logic tag_array7_load,
    input logic tag_array8_load,

    
    input logic valid_1_load,
    input logic valid_2_load,
    input logic valid_3_load,
    input logic valid_4_load,
    input logic valid_5_load,
    input logic valid_6_load,
    input logic valid_7_load,
    input logic valid_8_load,

    input logic write_sel_way_1,
    input logic write_sel_way_2,
    input logic write_sel_way_3,
    input logic write_sel_way_4,
    input logic write_sel_way_5,
    input logic write_sel_way_6,
    input logic write_sel_way_7,
    input logic write_sel_way_8,
    


    input logic read_dirty_array_1,
    input logic read_dirty_array_2,
    input logic read_dirty_array_3,
    input logic read_dirty_array_4,
    input logic read_dirty_array_5,
    input logic read_dirty_array_6,
    input logic read_dirty_array_7,
    input logic read_dirty_array_8,



    input logic LRU_read,

    input logic read_tag_array_1,
    input logic read_tag_array_2,
    input logic read_tag_array_3,
    input logic read_tag_array_4,
    input logic read_tag_array_5,
    input logic read_tag_array_6,
    input logic read_tag_array_7,
    input logic read_tag_array_8,


    input logic read_data_array_1,
    input logic read_data_array_2,
    input logic read_data_array_3,
    input logic read_data_array_4,
    input logic read_data_array_5,
    input logic read_data_array_6,
    input logic read_data_array_7,
    input logic read_data_array_8,


    input logic valid_1_in_read,
    input logic valid_2_in_read,
    input logic valid_3_in_read,
    input logic valid_4_in_read,
    input logic valid_5_in_read,
    input logic valid_6_in_read,
    input logic valid_7_in_read,
    input logic valid_8_in_read,

    input logic new_address_sel,

    input logic write_read_sel_1,
    input logic write_read_sel_2,
    input logic write_read_sel_3,
    input logic write_read_sel_4,
    input logic write_read_sel_5,
    input logic write_read_sel_6,
    input logic write_read_sel_7,
    input logic write_read_sel_8,
    

    input logic [2:0]which_tag,
//    input logic [31:0] mem_byte_enable256,
    input logic [6:0]LRU_in,
    input logic [2:0] cacheline_sel,
    input logic [255:0] cacheline_in,
    output logic [255:0] cacheline_out,
    output logic [23:0] tag_out,

    output logic Dirty1_out,
    output logic Dirty2_out,
    output logic Dirty3_out,
    output logic Dirty4_out,
    output logic Dirty5_out,
    output logic Dirty6_out,
    output logic Dirty7_out,
    output logic Dirty8_out,

    output logic hit1,
    output logic hit2,
    output logic hit3,
    output logic hit4,
    output logic hit5,
    output logic hit6,
    output logic hit7,
    output logic hit8,

    output logic [31:0] new_address,
    output logic [6:0]LRU_out
);
logic [s_tag-1:0] tag_array1_out;
logic [s_tag-1:0] tag_array2_out;
logic [s_tag-1:0] tag_array3_out;
logic [s_tag-1:0] tag_array4_out;
logic [s_tag-1:0] tag_array5_out;
logic [s_tag-1:0] tag_array6_out;
logic [s_tag-1:0] tag_array7_out;
logic [s_tag-1:0] tag_array8_out;


logic valid_1_out;
logic valid_2_out;
logic valid_3_out;
logic valid_4_out;
logic valid_5_out;
logic valid_6_out;
logic valid_7_out;
logic valid_8_out;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_1(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_1),
    .load(Dirty1_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty1_in),
    .dataout(Dirty1_out)
) ;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_2(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_2),
    .load(Dirty2_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty2_in),
    .dataout(Dirty2_out)
) ;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_3(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_3),
    .load(Dirty3_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty3_in),
    .dataout(Dirty3_out)
) ;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_4(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_4),
    .load(Dirty4_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty4_in),
    .dataout(Dirty4_out)
) ;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_5(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_5),
    .load(Dirty5_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty5_in),
    .dataout(Dirty5_out)
) ;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_6(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_6),
    .load(Dirty6_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty6_in),
    .dataout(Dirty6_out)
) ;

modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_7(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_7),
    .load(Dirty7_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty7_in),
    .dataout(Dirty7_out)
) ;


modular_array #(.s_index(s_index), .width(1))
dirty_bit_array_way_8(
    .clk(clk),
    .rst(rst),
    .read(read_dirty_array_8),
    .load(Dirty8_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(Dirty8_in),
    .dataout(Dirty8_out)
) ;

modular_array #(.s_index(s_index), .width(1))
valid_array_1(
    .clk(clk),
    .rst(rst),
    .read(valid_1_in_read),
    .load(valid_1_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_1_in),
    .dataout(valid_1_out)
) ;


modular_array #(.s_index(s_index), .width(1))
valid_array_2(
    .clk(clk),
    .rst(rst),
    .read(valid_2_in_read),
    .load(valid_2_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_2_in),
    .dataout(valid_2_out)
) ;

modular_array #(.s_index(s_index), .width(1))
valid_array_3(
    .clk(clk),
    .rst(rst),
    .read(valid_3_in_read),
    .load(valid_3_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_3_in),
    .dataout(valid_3_out)
) ;


modular_array #(.s_index(s_index), .width(1))
valid_array_4(
    .clk(clk),
    .rst(rst),
    .read(valid_4_in_read),
    .load(valid_4_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_4_in),
    .dataout(valid_4_out)
) ;

modular_array #(.s_index(s_index), .width(1))
valid_array_5(
    .clk(clk),
    .rst(rst),
    .read(valid_5_in_read),
    .load(valid_5_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_5_in),
    .dataout(valid_5_out)
) ;

modular_array #(.s_index(s_index), .width(1))
valid_array_6(
    .clk(clk),
    .rst(rst),
    .read(valid_6_in_read),
    .load(valid_6_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_6_in),
    .dataout(valid_6_out)
) ;

modular_array #(.s_index(s_index), .width(1))
valid_array_7(
    .clk(clk),
    .rst(rst),
    .read(valid_7_in_read),
    .load(valid_7_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_7_in),
    .dataout(valid_7_out)
) ;

modular_array #(.s_index(s_index), .width(1))
valid_array_8(
    .clk(clk),
    .rst(rst),
    .read(valid_8_in_read),
    .load(valid_8_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(valid_8_in),
    .dataout(valid_8_out)
) ;

modular_array #(.s_index(s_index), .width(24))
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

modular_array #(.s_index(s_index), .width(24))
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

modular_array #(.s_index(s_index), .width(24))
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

modular_array #(.s_index(s_index), .width(24))
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

modular_array #(.s_index(s_index), .width(24))
tag_array5(
    .clk(clk),
    .rst(rst),
    .read(read_tag_array_5),
    .load(tag_array5_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(address[31:s_offset+s_index]),
    .dataout(tag_array5_out)
);

modular_array #(.s_index(s_index), .width(24))
tag_array6(
    .clk(clk),
    .rst(rst),
    .read(read_tag_array_6),
    .load(tag_array6_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(address[31:s_offset+s_index]),
    .dataout(tag_array6_out)
);

modular_array #(.s_index(s_index), .width(24))
tag_array7(
    .clk(clk),
    .rst(rst),
    .read(read_tag_array_7),
    .load(tag_array7_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(address[31:s_offset+s_index]),
    .dataout(tag_array7_out)
);

modular_array #(.s_index(s_index), .width(24))
tag_array8(
    .clk(clk),
    .rst(rst),
    .read(read_tag_array_8),
    .load(tag_array8_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(address[31:s_offset+s_index]),
    .dataout(tag_array8_out)
);

modular_array #(.s_index(s_index), .width(7))
PLRU_array(
    .clk(clk),
    .rst(rst),
    .read(LRU_read),
    .load(LRU_load),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(LRU_in),
    .dataout(LRU_out)
) ;

logic write_en_way_1, write_en_way_2, write_en_way_3, write_en_way_4, write_en_way_5, write_en_way_6, write_en_way_7, write_en_way_8; 
logic [255:0] cache_line_data_out_1, cache_line_data_out_2, cache_line_data_out_3, cache_line_data_out_4, cache_line_data_out_5, cache_line_data_out_6, cache_line_data_out_7, cache_line_data_out_8;
logic [255:0] data_in_1, data_in_2, data_in_3, data_in_4, data_in_5, data_in_6, data_in_7, data_in_8;

modular_data_array w1(
    .clk(clk),
    .read(read_data_array_1),
    .write_en(write_en_way_1),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_1),
    .dataout(cache_line_data_out_1)
);


modular_data_array w2(
    .clk(clk),
    .read(read_data_array_2),
    .write_en(write_en_way_2),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_2),
    .dataout(cache_line_data_out_2)
);

modular_data_array w3(
    .clk(clk),
    .read(read_data_array_3),
    .write_en(write_en_way_3),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_3),
    .dataout(cache_line_data_out_3)
);


modular_data_array w4(
    .clk(clk),
    .read(read_data_array_4),
    .write_en(write_en_way_4),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_4),
    .dataout(cache_line_data_out_4)
);

modular_data_array w5(
    .clk(clk),
    .read(read_data_array_5),
    .write_en(write_en_way_5),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_5),
    .dataout(cache_line_data_out_5)
);


modular_data_array w6(
    .clk(clk),
    .read(read_data_array_6),
    .write_en(write_en_way_6),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_6),
    .dataout(cache_line_data_out_6)
);

modular_data_array w7(
    .clk(clk),
    .read(read_data_array_7),
    .write_en(write_en_way_7),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_7),
    .dataout(cache_line_data_out_7)
);


modular_data_array w8(
    .clk(clk),
    .read(read_data_array_8),
    .write_en(write_en_way_8),
    .rindex(address[s_offset+s_index-1:s_offset]),
    .windex(address[s_offset+s_index-1:s_offset]),
    .datain(data_in_8),
    .dataout(cache_line_data_out_8)
);


always_comb begin

    case (write_read_sel_1) 
    1'b0: data_in_1 = cacheline_in;
    1'b1: data_in_1 = mem_wdata256;
    endcase

    case(write_read_sel_2)
    1'b0: data_in_2 = cacheline_in;
    1'b1: data_in_2 = mem_wdata256;
    endcase
    
    case (write_read_sel_3) 
    1'b0: data_in_3 = cacheline_in;
    1'b1: data_in_3 = mem_wdata256;
    endcase

    case(write_read_sel_4)
    1'b0: data_in_4 = cacheline_in;
    1'b1: data_in_4 = mem_wdata256;
    endcase

    case (write_read_sel_5) 
    1'b0: data_in_5 = cacheline_in;
    1'b1: data_in_5 = mem_wdata256;
    endcase

    case(write_read_sel_6)
    1'b0: data_in_6 = cacheline_in;
    1'b1: data_in_6 = mem_wdata256;
    endcase
    
    case (write_read_sel_7) 
    1'b0: data_in_7 = cacheline_in;
    1'b1: data_in_7 = mem_wdata256;
    endcase

    case(write_read_sel_8)
    1'b0: data_in_8 = cacheline_in;
    1'b1: data_in_8 = mem_wdata256;
    endcase

    case (new_address_sel)
    1'b0: new_address = {address[31:5],5'b0};
    1'b1: new_address = {tag_out, address[s_offset+s_index-1:s_offset],5'b0};
    endcase

    case (cacheline_sel)
        3'b000:  cacheline_out =  cache_line_data_out_1 ;
        3'b001:  cacheline_out =  cache_line_data_out_2 ;
        3'b010:  cacheline_out =  cache_line_data_out_3 ;
        3'b011:  cacheline_out =  cache_line_data_out_4 ; 
        3'b100:  cacheline_out =  cache_line_data_out_5 ;
        3'b101:  cacheline_out =  cache_line_data_out_6 ;
        3'b110:  cacheline_out =  cache_line_data_out_7 ;
        3'b111:  cacheline_out =  cache_line_data_out_8 ; 
    endcase
	
	write_en_way_1 = write_sel_way_1;
	write_en_way_2 = write_sel_way_2;
	write_en_way_3 = write_sel_way_3;
	write_en_way_4 = write_sel_way_4;
	write_en_way_5 = write_sel_way_5;
	write_en_way_6 = write_sel_way_6;
	write_en_way_7 = write_sel_way_7;
	write_en_way_8 = write_sel_way_8;


   /* 
    unique case (write_sel_way_1)
        2'b10: write_en_way_1 = mem_byte_enable256;
        2'b01: write_en_way_1 = {32{1'b1}};// mem_byte_enable256;
        default: write_en_way_1 = {32{1'b0}};
    endcase
    unique case (write_sel_way_2)
        2'b10: write_en_way_2 = mem_byte_enable256;
        2'b01: write_en_way_2 =  {32{1'b1}};//mem_byte_enable256;
        default: write_en_way_2 = {32{1'b0}};
    endcase
    unique case (write_sel_way_3)
        2'b10: write_en_way_3 = mem_byte_enable256;
        2'b01: write_en_way_3 = {32{1'b1}};// mem_byte_enable256;
        default: write_en_way_3 = {32{1'b0}};
    endcase
    unique case (write_sel_way_4)
        2'b10: write_en_way_4 = mem_byte_enable256;
        2'b01: write_en_way_4 =  {32{1'b1}};//mem_byte_enable256;
        default: write_en_way_4 = {32{1'b0}};
    endcase
    unique case (write_sel_way_5)
        2'b10: write_en_way_5 = mem_byte_enable256;
        2'b01: write_en_way_5 = {32{1'b1}};// mem_byte_enable256;
        default: write_en_way_5 = {32{1'b0}};
    endcase
    unique case (write_sel_way_6)
        2'b10: write_en_way_6 = mem_byte_enable256;
        2'b01: write_en_way_6 =  {32{1'b1}};//mem_byte_enable256;
        default: write_en_way_6 = {32{1'b0}};
    endcase
    unique case (write_sel_way_7)
        2'b10: write_en_way_7 = mem_byte_enable256;
        2'b01: write_en_way_7 = {32{1'b1}};// mem_byte_enable256;
        default: write_en_way_7 = {32{1'b0}};
    endcase
    unique case (write_sel_way_8)
        2'b10: write_en_way_8 = mem_byte_enable256;
        2'b01: write_en_way_8 =  {32{1'b1}};//mem_byte_enable256;
        default: write_en_way_8 = {32{1'b0}};
    endcase
*/
    


    
    case(which_tag) 
        3'b000: tag_out = tag_array1_out; 
        3'b001: tag_out = tag_array2_out;
        3'b010: tag_out = tag_array3_out;
        3'b011: tag_out = tag_array4_out; 
        3'b100: tag_out = tag_array5_out;
        3'b101: tag_out = tag_array6_out;
        3'b110: tag_out = tag_array7_out;
        3'b111: tag_out = tag_array8_out;
    endcase
    unique case (read_tag_array_1)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array1_out) && valid_1_out) begin
                hit1 = 1'b1;
            end
            else  
                hit1=1'b0;
        end 
        default: hit1 = 1'b0;
    endcase

    unique case (read_tag_array_2)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array2_out) && valid_2_out) begin
                hit2 = 1'b1;
            end
            else 
                hit2=1'b0;
        end 
        default: hit2 = 1'b0;
    endcase


    unique case (read_tag_array_3)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array3_out) && valid_3_out) begin
                hit3 = 1'b1;
            end
            else  
                hit3=1'b0;
        end 
        default: hit3 = 1'b0;
    endcase

  unique case (read_tag_array_4)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array4_out) && valid_4_out) begin
                hit4 = 1'b1;
            end
            else  
                hit4=1'b0;
        end 
        default: hit4 = 1'b0;
    endcase

    unique case (read_tag_array_5)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array5_out) && valid_5_out) begin
                hit5 = 1'b1;
            end
            else 
                hit5 =1'b0;
        end 
        default: hit5 = 1'b0;
    endcase


    unique case (read_tag_array_6)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array6_out) && valid_6_out) begin
                hit6 = 1'b1;
            end
            else  
                hit6=1'b0;
        end 
        default: hit6 = 1'b0;
    endcase


    unique case (read_tag_array_7)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array7_out) && valid_7_out) begin
                hit7 = 1'b1;
            end
            else 
                hit7 =1'b0;
        end 
        default: hit7 = 1'b0;
    endcase


    unique case (read_tag_array_8)
        1'b1: begin
            if((address[31:s_offset+s_index] == tag_array8_out) && valid_8_out) begin
                hit8 = 1'b1;
            end
            else  
                hit8=1'b0;
        end 
        default: hit8 = 1'b0;
    endcase

end



endmodule : modular_cache_datapath
