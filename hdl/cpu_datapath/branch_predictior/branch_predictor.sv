module br_pred_blkbox
import rv32i_types::*;
(
	input clk,
	input rst,
	
	input logic read,
	input logic load,
	input logic stall,
	input logic br_taken,
	input rv32i_word pc_in,
	input rv32i_word pc_mem_stage,

	//output logic stall_pc,
	//output logic stall_nop_ifid,
	output logic flush
);
logic global_flush;//global_stall_pc, global_stall_nop_ifid, global_flush;
//assign stall_pc = global_stall_pc;
//assign stall_nop_ifid = global_stall_nop_ifid;
//assign flush = global_flush;

logic local_flush;//, local_stall_nop_ifid, local_flush;
//assign stall_pc = local_stall_pc;
//assign stall_nop_ifid = local_stall_nop_ifid;
//assign flush = local_flush;

logic predict_sel;
global_br_pred GBR_PRED (
	.clk(clk),
	.rst(rst),
	.read(read),
	.load(load),
	.stall(stall),
	.taken(br_taken),
	.pc_in(pc_in),
	.pc_mem_stage(pc_mem_stage),

	//.stall_pc(global_stall_pc),
	//.stall_nop_ifid(global_stall_nop_ifid),
	.flush(global_flush)
);
local_br_pred LBR_PRED (
	.clk(clk),
	.rst(rst),
	.read(read),
	.load(load),
	.stall(stall),
	.taken(br_taken),
	.pc_in(pc_in),
	.pc_mem_stage(pc_mem_stage),

	//.stall_pc(local_stall_pc),
	//.stall_nop_ifid(local_stall_nop_ifid),
	.flush(local_flush)
);
meta_pred META_PRED (
	.clk(clk),
	.rst(rst),
	.read(read),
	.load(load),
	.stall(stall),
	.taken(br_taken),
	.pc_in(pc_in),
	.pc_mem_stage(pc_mem_stage),

	.br_pred_sel(predict_sel)
);

/******** MUXES ********/
//assign predict_sel = 1'b0;
// select from the two pranch predictors
always_comb begin
	case (predict_sel)
		1'b0: begin // take global predictor
			//stall_pc = global_stall_pc;
			//stall_nop_ifid = global_stall_nop_ifid;
			flush = global_flush;	
		end
		1'b1: begin // take local predictor
			//stall_pc = local_stall_pc;
			//stall_nop_ifid = local_stall_nop_ifid;
			flush = local_flush;	
		end
	endcase
end
endmodule : br_pred_blkbox
