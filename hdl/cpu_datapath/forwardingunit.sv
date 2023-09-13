module forwardingunit
import rv32i_types::*;
( 
    input rv32i_reg rs1_id_IdEx, rs2_id_IdEx, rs2_id_ExMem, rd_id_MemWb, rd_id_ExMem,
    input rv32i_control_word control_word_IdEx, control_word_ExMem, control_word_MemWb,
    output alumux::alumux1_sel_t alumux1_sel,
    output alumux::alumux2_sel_t alumux2_sel,
    output cachemux::cachemux_sel_t cachemux_sel,
    output cmpmux::cmpmux1_sel_t cmpmux1_sel,
    output cmpmux:: cmpmux2_sel_t cmpmux2_sel,
	output logic [1:0] rs2passmux_sel
);

logic write_reg_ExMem, write_reg_MemWb, write_mem_ExMem, read_mem_MemWb;
alumux::alumux1_sel_t alumux1_IdEx;
alumux::alumux2_sel_t alumux2_IdEx;
cmpmux::cmpmux2_sel_t cmpmux2_IdEx;

assign write_reg_ExMem = control_word_ExMem.write_reg;
assign write_reg_MemWb = control_word_MemWb.write_reg;
assign write_mem_ExMem = control_word_ExMem.write_mem;
assign read_mem_MemWb = control_word_MemWb.read_mem;

assign alumux1_IdEx = control_word_IdEx.alumux1_sel;
assign alumux2_IdEx = control_word_IdEx.alumux2_sel;
assign cmpmux2_IdEx = control_word_IdEx.cmpmux2_sel;

rv32i_opcode execute_opcode, mem_opcode, wb_opcode;
assign execute_opcode = control_word_IdEx.opcode; 
assign mem_opcode = control_word_ExMem.opcode;
assign wb_opcode = control_word_MemWb.opcode;
logic ex_mem_opcode_check, ex_wb_opcode_check;
assign ex_mem_opcode_check = ~((execute_opcode != op_br) & (mem_opcode != op_br));
assign ex_wb_opcode_check = ~((execute_opcode != op_br) & (wb_opcode != op_br));

always_comb begin
    //At the beginning use the  non fowarded select then if's will change if needed.
    alumux1_sel = alumux1_IdEx;
    alumux2_sel = alumux2_IdEx;
    cmpmux2_sel = cmpmux2_IdEx;

    //defualt  no mux sel
    cmpmux1_sel = cmpmux::rs1_out;
    
    //foward from ex to rs1 input
    if(write_reg_ExMem && (rd_id_ExMem == rs1_id_IdEx) && rs1_id_IdEx != 0 && execute_opcode != op_br)
        alumux1_sel = alumux::alu_out_ExMem1;
    //foward from ex to rs2 input
    if(write_reg_ExMem && (rd_id_ExMem == rs2_id_IdEx) && rs2_id_IdEx != 0 && execute_opcode != op_br && execute_opcode != op_store)
        alumux2_sel = alumux::alu_out_ExMem2;
    //foward from  mem to rs1
    if(write_reg_MemWb && !(write_reg_ExMem && (rd_id_ExMem == rs1_id_IdEx)) && (rd_id_MemWb == rs1_id_IdEx) && rs1_id_IdEx != 0 && execute_opcode != op_br)
        alumux1_sel = alumux::r_data_MemWb1;
    //foward from mem to rs2
    if(write_reg_MemWb && !(write_reg_ExMem && (rd_id_ExMem == rs2_id_IdEx)) && (rd_id_MemWb == rs2_id_IdEx) && rs2_id_IdEx != 0 && execute_opcode != op_br && execute_opcode != op_store)
        alumux2_sel = alumux::r_data_MemWb2;

    //foward from memrdata to memwdata
   if((write_mem_ExMem) && (read_mem_MemWb && write_reg_MemWb) && (rs2_id_ExMem == rd_id_MemWb))
        cachemux_sel = cachemux::r_data_MemWb;
   else
        cachemux_sel = cachemux::rs2_out_ExMem;

    //foward the into the compare unit
    if(write_reg_ExMem && rd_id_ExMem == rs2_id_IdEx /*&& ex_mem_opcode_check*/ && rs2_id_IdEx != 0)
        cmpmux2_sel = cmpmux::alu_out_ExMem2;
    if(write_reg_ExMem && rd_id_ExMem == rs1_id_IdEx /*&& ex_mem_opcode_check*/ && rs1_id_IdEx != 0)
        cmpmux1_sel = cmpmux::alu_out_ExMem1;
    if(write_reg_MemWb && !(write_reg_ExMem && (rd_id_ExMem == rs2_id_IdEx)) && (rd_id_MemWb == rs2_id_IdEx) /*&& ex_wb_opcode_check*/ && rs2_id_IdEx != 0)
        cmpmux2_sel = cmpmux::r_data_MemWb2;
    //foward from mem to rs2
    if(write_reg_MemWb && !(write_reg_ExMem && (rd_id_ExMem == rs1_id_IdEx)) && (rd_id_MemWb == rs1_id_IdEx) /*&& ex_wb_opcode_check*/ && rs1_id_IdEx != 0)
        cmpmux1_sel = cmpmux::r_data_MemWb1;

	rs2passmux_sel = 2'b00;
  	// forward the correct rs2 value in the pass through
	if (write_reg_ExMem && execute_opcode == op_store && rd_id_ExMem == rs2_id_IdEx && rs2_id_IdEx != 0)
		rs2passmux_sel = 2'b01;
	if (!(write_reg_ExMem && (rd_id_ExMem == rs2_id_IdEx)) && execute_opcode == op_store && rd_id_MemWb == rs2_id_IdEx && rs2_id_IdEx != 0)
		rs2passmux_sel = 2'b10;

    
        
end

endmodule : forwardingunit
