module instr_decode 
import rv32i_types::*;
(   input clk,
    input rst,
    input load,
    input rv32i_word instr_mem_rdata,
    input rv32i_reg rd_in,
	input rv32i_word pc_in, 
    input rv32i_word mem_wb_mux_out,
    input logic i_cache_miss,
    input logic d_cache_miss,
	//input logic update_hist_table,
	//input logic flush_info,
    input rv32i_reg id_ex_rsd_id, // Dest Reg for the supposed LD
    input logic id_ex_read_mem, // from control word from ID/EX (Check if Load)
	input rv32i_word pc_reg_val_in,
	//input rv32i_word pc_mem_stage,
	//input logic br_taken_ex_stage,
	//input rv32i_opcode opcode_ex_stage,

	output rv32i_word pc_reg_val_out,
    output rv32i_word i_imm_out,
    output rv32i_word s_imm_out,
    output rv32i_word b_imm_out,
    output rv32i_word u_imm_out,
    output rv32i_word j_imm_out,
    output rv32i_word rs1_data_out,
    output rv32i_word rs2_data_out,
    output rv32i_reg rd_out,
    output rv32i_reg rs1_id,
    output rv32i_reg rs2_id,
    output [2:0] funct3_out,
    output rv32i_control_word control_word_out,
	output rv32i_opcode opcode_out,

    output logic pc_stall,
    output logic stall_if_id,
    output logic stall_id_ex,
    output logic stall_ex_mem,
    output logic stall_mem_wb,
    output logic stall_nop_if_id,
    output logic stall_nop_id_ex,

	input logic br_pred_in,
	output logic br_pred_out,
	input rv32i_word br_pred_pc_in,
	output rv32i_word br_pred_pc_out
/*
	output logic br_pred_stall_pc,
	output logic br_pred_stall_nop,
	output logic br_pred_taken,
	output rv32i_word br_pred_pc_out
*/
);
/*
rv32i_reg rs1;
rv32i_reg rs2;
*/


//I thikn we should figure out control word here bc here we know the values of fuct3 funct7 and opcode
assign opcode_out = rv32i_opcode'(instr_mem_rdata[6:0]);
assign pc_reg_val_out = pc_reg_val_in;
assign funct3_out = instr_mem_rdata[14:12];
// assign funct7 = instr_mem_rdata[31:25];
// assign opcode = rv32i_opcode'(instr_mem_rdata[6:0]);
//assign control_word_out = ;//do somehting here
assign i_imm_out = {{21{instr_mem_rdata[31]}}, instr_mem_rdata[30:20]};
assign s_imm_out = {{21{instr_mem_rdata[31]}}, instr_mem_rdata[30:25], instr_mem_rdata[11:7]};
assign b_imm_out = {{20{instr_mem_rdata[31]}}, instr_mem_rdata[7], instr_mem_rdata[30:25], instr_mem_rdata[11:8], 1'b0};
assign u_imm_out = {instr_mem_rdata[31:12], 12'h000};
assign j_imm_out = {{12{instr_mem_rdata[31]}}, instr_mem_rdata[19:12], instr_mem_rdata[20], instr_mem_rdata[30:21], 1'b0};
assign br_pred_out = br_pred_in;
assign br_pred_pc_out = br_pred_pc_in;
/*
assign rs1_id = instr_mem_rdata[19:15];
assign rs2_id = instr_mem_rdata[24:20];
assign rd_out = instr_mem_rdata[11:7];
*/

regfile regfile(
.clk(clk), 
.rst(rst), 
.load(load), 
.in(mem_wb_mux_out),
.src_a(rs1_id), 
.src_b(rs2_id), 
.dest(rd_in),
.reg_a(rs1_data_out), 
.reg_b(rs2_data_out)
);


// Control Word Generation
WordGenerator WRDGEN (
	.opcode(rv32i_opcode'(instr_mem_rdata[6:0])),
	.funct3(instr_mem_rdata[14:12]),
	.funct7(instr_mem_rdata[31:25]),
	.ctrl(control_word_out)
);

stall stall(
    .i_cache_miss(i_cache_miss),
    .d_cache_miss(d_cache_miss),

    .id_ex_rsd_id(id_ex_rsd_id),
    .if_id_rs1_id(rs1_id), 
    .if_id_rs2_id(rs2_id), 
    .id_ex_read_mem(id_ex_read_mem), // from control word



   .pc_stall(pc_stall),
   .stall_if_id(stall_if_id),
   .stall_id_ex(stall_id_ex),
   .stall_ex_mem(stall_ex_mem),
   .stall_mem_wb(stall_mem_wb),
   .stall_nop_if_id(stall_nop_if_id),
   .stall_nop_id_ex(stall_nop_id_ex)
   
);


always_comb begin
	//rs1_id = instr_mem_rdata[19:15];
	//rs2_id = instr_mem_rdata[24:20];
	//rd_out = instr_mem_rdata[11:7];
	rs1_id = 5'b0;
	rs2_id = 5'b0;
	rd_out = 5'b0;
	case (opcode_out)
		op_lui: begin
			rd_out = instr_mem_rdata[11:7];
		end
		op_auipc: begin
			rd_out = instr_mem_rdata[11:7];	
		end
		op_jal: begin
			rd_out = instr_mem_rdata[11:7];
		end
		op_jalr: begin
			rs1_id = instr_mem_rdata[19:15];
			rd_out = instr_mem_rdata[11:7];
		end
		op_load: begin
			rs1_id = instr_mem_rdata[19:15];
			rd_out = instr_mem_rdata[11:7];
		end
		op_imm: begin
			rs1_id = instr_mem_rdata[19:15];	
			rd_out = instr_mem_rdata[11:7];
		end
		op_reg: begin
			rs1_id = instr_mem_rdata[19:15];	
			rs2_id = instr_mem_rdata[24:20];	
			rd_out = instr_mem_rdata[11:7];
		end
		op_br: begin
			rs1_id = instr_mem_rdata[19:15];	
			rs2_id = instr_mem_rdata[24:20];	
		end
		op_store: begin
			rs1_id = instr_mem_rdata[19:15];		
			rs2_id = instr_mem_rdata[24:20];	
		end
	endcase
end
/*
logic br_pred_taken_temp;
logic br_pred_stall_nop_temp;

// BRANCH PREDICTOR CALL
br_pred_blkbox BR_PREDICTOR (
	.clk(clk),
	.rst(rst),
	.read((opcode_out == op_br)),
	.load(update_hist_table),
	.stall(stall_id_ex || stall_nop_id_ex),
	.br_taken(flush_info),
	.pc_in(pc_in),
	.pc_mem_stage(pc_mem_stage),
	.stall_pc(br_pred_stall_pc),
	.stall_nop_ifid(br_pred_stall_nop_temp),
	.flush(br_pred_taken_temp)
);

always_comb begin
	if (br_pred_taken_temp) begin
		br_pred_pc_out = pc_in + b_imm_out;
	end
	
	if (opcode_out != op_br)
		br_pred_taken = 1'b0;
	else
		br_pred_taken = br_pred_taken_temp;

	if (opcode_ex_stage == op_br && br_taken_ex_stage) 
		br_pred_stall_nop = br_pred_stall_nop_temp;
	else 
		br_pred_stall_nop = br_pred_stall_nop_temp;
end*/

endmodule:instr_decode



