package pcmux;
typedef enum bit [1:0] {
    pc_plus4  = 2'b00
    ,alu_out  = 2'b01
    ,alu_mod2 = 2'b10
    ,cmp_out =  2'b11   //added this to deal with cmp case
} pcmux_sel_t;
endpackage


package marmux;
typedef enum bit {
    pc_out = 1'b0
    ,alu_out = 1'b1
} marmux_sel_t;
endpackage

package cmpmux;

typedef enum bit[1:0] {
    rs1_out = 2'b00
    ,alu_out_ExMem1 = 2'b01
    ,r_data_MemWb1 = 2'b10
} cmpmux1_sel_t;


typedef enum bit[1:0] {
    rs2_out = 2'b00
    ,i_imm = 2'b01
    ,alu_out_ExMem2 = 2'b10
    ,r_data_MemWb2 = 2'b11
} cmpmux2_sel_t;

endpackage

package alumux;
typedef enum bit[1:0] {
    rs1_out = 2'b00
    ,pc_out = 2'b01
    ,alu_out_ExMem1 = 2'b10
    ,r_data_MemWb1 = 2'b11
} alumux1_sel_t;

typedef enum bit [2:0] {
    i_imm    = 3'b000
    ,u_imm   = 3'b001
    ,b_imm   = 3'b010
    ,s_imm   = 3'b011
    ,j_imm   = 3'b100
    ,rs2_out = 3'b101
    ,alu_out_ExMem2 = 3'b110
    ,r_data_MemWb2 = 3'b111
} alumux2_sel_t;
endpackage

package regfilemux;
typedef enum bit [3:0] {
    alu_out   = 4'b0000
    ,br_en    = 4'b0001
    ,u_imm    = 4'b0010
    ,lw       = 4'b0011
    ,pc_plus4 = 4'b0100
    ,lb        = 4'b0101
    ,lbu       = 4'b0110  // unsigned byte
    ,lh        = 4'b0111
    ,lhu       = 4'b1000  // unsigned halfword
} regfilemux_sel_t;
endpackage

package cachemux;
typedef enum bit {
    r_data_MemWb     = 1'b0
    ,rs2_out_ExMem   = 1'b1
} cachemux_sel_t;
endpackage



