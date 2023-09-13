module stall

import rv32i_types::*;
(
    input logic i_cache_miss,
    input logic d_cache_miss,

    input rv32i_reg id_ex_rsd_id,
    input logic id_ex_read_mem, // from control word
    input rv32i_reg if_id_rs1_id, 
    input rv32i_reg if_id_rs2_id, 


    output logic pc_stall,
    output logic stall_if_id,
    output logic stall_id_ex,
    output logic stall_ex_mem,
    output logic stall_mem_wb,
    output logic stall_nop_if_id,
    output logic stall_nop_id_ex
);
                            
always_comb begin
    stall_if_id = 1'b0;
    stall_id_ex = 1'b0;
    stall_ex_mem = 1'b0;
    stall_mem_wb = 1'b0;
    pc_stall = 1'b0;
    stall_nop_if_id = 1'b0;
    stall_nop_id_ex = 1'b0;

    if(d_cache_miss) begin
        stall_if_id |= 1'b1;
        stall_id_ex |= 1'b1;
        stall_ex_mem |= 1'b1;
        stall_mem_wb |= 1'b1;
        pc_stall |= 1'b1;
        stall_nop_if_id |= 1'b0;
        stall_nop_id_ex |= 1'b0; 
    end
    else if (i_cache_miss) begin
        stall_if_id |= 1'b1;
        stall_id_ex |= 1'b1;
        stall_ex_mem |= 1'b1;
        stall_mem_wb |= 1'b1;
        pc_stall |= 1'b1;
        stall_nop_if_id |= 1'b0;
        stall_nop_id_ex |= 1'b0; 
    end
	else if ( (id_ex_read_mem) && ((id_ex_rsd_id == if_id_rs1_id) || (id_ex_rsd_id == if_id_rs2_id) )) begin
        stall_if_id |= 1'b1;
        stall_id_ex |= 1'b1;
        stall_ex_mem |= 1'b0;
        stall_mem_wb |= 1'b0;
        pc_stall |= 1'b1;
        stall_nop_if_id |= 1'b0;
        stall_nop_id_ex |= 1'b1; //look at this and above while debugging
	end
end
endmodule : stall
