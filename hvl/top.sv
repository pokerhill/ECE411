module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// Dump signals
initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, mp4_tb, "+all");
end
/****************************** End do not touch *****************************/


/************************ Signals necessary for monitor **********************/
// This section not required until CP2

// assign stall signals
logic stall_pc, stall_ifid, stall_idex, stall_exmem, stall_memwb;
assign stall_pc = dut.INSTR_DECODE.pc_stall;
assign stall_ifid = dut.INSTR_DECODE.stall_if_id | dut.INSTR_DECODE.stall_nop_if_id;
assign stall_idex = dut.INSTR_DECODE.stall_id_ex | dut.INSTR_DECODE.stall_nop_id_ex;
assign stall_exmem = dut.INSTR_DECODE.stall_ex_mem;
assign stall_memwb = dut.INSTR_DECODE.stall_mem_wb;


rv32i_types::rv32i_word pc_ifid, pc_idex, pc_exmem, pc_memwb,pc_memwb_in;
rv32i_types::rv32i_word rs1_id_ifid, rs1_id_idex, rs1_id_exmem, rs1_id_memwb;
rv32i_types::rv32i_word rs2_id_ifid, rs2_id_idex, rs2_id_exmem, rs2_id_memwb;
rv32i_types::rv32i_word rs1_val_ifid, rs1_val_idex, rs1_val_exmem, rs1_val_memwb;
rv32i_types::rv32i_word rs2_val_ifid, rs2_val_idex, rs2_val_exmem, rs2_val_memwb;
rv32i_types::rv32i_word instr_ifid, instr_idex, instr_exmem, instr_memwb;
rv32i_types::rv32i_word pc_in_ifid, pc_in_idex, pc_in_exmem, pc_in_memwb, pc_out_ifid;
rv32i_types::rv32i_word dcache_addr_mem, dcache_addr_wb, dcache_rdata, dcache_wdata, dcache_rmbe, dcache_wmbe;


// grab signals
always_ff @(posedge itf.clk) begin
	if (~stall_pc) begin
	;	
	end
	if (~stall_ifid) begin
		pc_in_ifid <= dut.INSTR_FETCH.PC.in;
		pc_out_ifid <=  dut.INSTR_FETCH.PC.out;
		instr_ifid <= (dut.IF_ID.stall_nop || dut.IF_ID.flush) ? 32'h00000013 : dut.IF_ID.instr_mem_rdata; 
	end
	if (~stall_idex) begin
		rs1_id_idex <= (dut.ID_EX.flush) ? 5'b0 : dut.ID_EX.rs1_id_in;
		rs2_id_idex <= (dut.ID_EX.flush) ? 5'b0 : dut.ID_EX.rs2_id_in;
		rs1_val_idex <= (dut.ID_EX.flush) ? 32'b0 : dut.ID_EX.reg_1_in;
		rs2_val_idex <= (dut.ID_EX.flush) ? 32'b0 : dut.ID_EX.reg_1_in;

		pc_in_idex <= pc_out_ifid;
		instr_idex <= (dut.ID_EX.flush) ? 32'h00000013 : instr_ifid;
	end
	if (~stall_exmem) begin
		dcache_addr_mem <= dut.EX_MEM.alu_val_out;
		

		rs1_id_exmem <= (dut.EX_MEM.flush) ? 5'b0 : rs1_id_idex;
		rs2_id_exmem <= (dut.EX_MEM.flush) ? 5'b0 : rs2_id_idex;
		rs1_val_exmem <= (dut.EX_MEM.flush) ? 32'b0 : rs1_val_idex;
		rs2_val_exmem <= (dut.EX_MEM.flush) ? 32'b0 : rs2_val_idex;
		pc_in_exmem <= (dut.MEM_STAGE.flush) ? dut.EX_MEM.alu_val_out: pc_in_idex;
		instr_exmem <= (dut.EX_MEM.flush) ? 32'h00000013 : instr_idex;
	end
	if (~stall_memwb) begin
		pc_memwb <= dut.MEM_WB.reg_pc_out;
		pc_memwb_in <= pc_in_exmem;
		dcache_addr_wb <= dut.MEM_BB.d_cache_address;
		dcache_rdata <= dut.MEM_BB.d_cache_rdata;
		dcache_wdata <= dut.MEM_BB.d_cache_wdata;
		dcache_rmbe <= (dut.MEM_BB.d_cache_read) ? 4'b1111 : 4'b0;
		dcache_wmbe <= (dut.MEM_BB.d_cache_write) ? dut.MEM_BB.d_cache_byte_enable : 4'b0;

		rs1_id_memwb <= rs1_id_exmem;
		rs2_id_memwb <= rs2_id_exmem;
		rs1_val_memwb <= rs1_val_exmem;
		rs2_val_memwb <= rs2_val_exmem;
		pc_in_memwb <= pc_in_exmem;
		instr_memwb <= instr_exmem;
	end
end



//assign rvfi.commit = 0;
// assign itf.halt = 
// logic wb_commit;
assign rvfi.pc_rdata = pc_out_ifid;
assign rvfi.pc_wdata = pc_memwb; 
assign wb_commit = dut.MEM_WB.cntrl_word_out.write_reg & (dut.MEM_WB.reg_dest_out == '0); 
assign rvfi.commit = ~stall_memwb && wb_commit && ~dut.MEM_STAGE.flush  ; // Set high when a valid instruction is modifying regfile or PC
//assign rvfi.halt = 0; // Set high when target PC == Current PC for a branch
assign rvfi.halt = (rvfi.commit && (rvfi.pc_rdata == rvfi.pc_wdata)); // Set high when target PC == Current PC for a branch
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO
always @(posedge itf.clk) begin

//$monitor("[monitor] value of commit %0d pc_rdata %0d pc_wdata %0d", rvfi.commit, rvfi.pc_rdata, rvfi.pc_wdata);

    if (rvfi.halt)
	begin
		//$monitor("[monitor] value of commit %0d pc_rdata %0d pc_wdata %0d", rvfi.commit, rvfi.pc_rdata, rvfi.pc_wdata);
		$display ("FINISHED RUNNING");
        $finish;
	end
end
/*
//Instruction and trap:
assign rvfi.inst = instr_memwb;
assign rvfi.trap = 1'b0;

//Regfile:
assign rvfi.rs1_addr = rs1_id_memwb;
assign rvfi.rs2_addr = rs2_id_memwb;
assign rvfi.rs1_rdata = rs1_val_memwb;
assign rvfi.rs2_rdata = rs2_val_memwb;
assign rvfi.load_regfile = dut.MEM_WB.cntrl_word_out.write_reg;
assign rvfi.rd_addr = dut.WB_STAGE.reg_dest_in;
assign rvfi.rd_wdata = dut.WB_STAGE.regfilemux_out;

//PC:
assign rvfi.pc_rdata = pc_memwb;
assign rvfi.pc_wdata = pc_in_exmem;

//Memory:
assign rvfi.mem_addr = dcache_addr_wb;
assign rvfi.mem_rmask = dcache_rmbe;
assign rvfi.mem_wmask = dcache_wmbe;
assign rvfi.mem_rdata = dcache_rdata;
assign rvfi.mem_wdata = dcache_wdata;

//Please refer to rvfi_itf.sv for more information.
*/

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = '{default: '0};

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level for CP2:
Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),
    
/*     // Remove after CP1
    .instr_mem_resp(itf.inst_resp),
    .instr_mem_rdata(itf.inst_rdata),
	.data_mem_resp(itf.data_resp),
    .data_mem_rdata(itf.data_rdata),
    .instr_read(itf.inst_read),
	.instr_mem_address(itf.inst_addr),
    .data_read(itf.data_read),
    .data_write(itf.data_write),
    .data_mbe(itf.data_mbe),
    .data_mem_address(itf.data_addr),
    .data_mem_wdata(itf.data_wdata)
*/

  // Use for CP2 onwards
    .pmem_read(itf.mem_read),
    .pmem_write(itf.mem_write),
    .pmem_wdata(itf.mem_wdata),
    .pmem_rdata(itf.mem_rdata),
    .pmem_address(itf.mem_addr),
    .pmem_resp(itf.mem_resp)
    
);
/***************************** End Instantiation *****************************/

endmodule
