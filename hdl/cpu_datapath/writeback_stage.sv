module writeback_stage
import rv32i_types::*;
(   
	input rv32i_control_word cntrl_word_in,
	input logic br_en,
	input rv32i_word alu_out_preg,
	input rv32i_word pc_out,
	input rv32i_reg reg_dest_in,
	input rv32i_word u_imm_preg,
	input rv32i_word rdata_preg,

    output rv32i_word regfilemux_out,
	output rv32i_reg rd_out,
	input rv32i_opcode opcode_in
);
logic [2:0] addr_lsb_preg; 
assign addr_lsb_preg = alu_out_preg[1:0];
assign rd_out = reg_dest_in;
always_comb begin
    //Modified from mdr to use rdata_reg
    unique case (cntrl_word_in.regfilemux_sel)
        regfilemux::alu_out: regfilemux_out = alu_out_preg;
        regfilemux::br_en: regfilemux_out = {{31{1'b0}},br_en}; //zext
        regfilemux::u_imm: regfilemux_out = u_imm_preg;
        regfilemux::lw: regfilemux_out = rdata_preg;  
        regfilemux::pc_plus4: regfilemux_out = pc_out + 4;
        regfilemux::lb: begin
            case(addr_lsb_preg)
                2'b00: regfilemux_out = {{24{rdata_preg[7]}}, rdata_preg[7:0]};
                2'b01: regfilemux_out = {{24{rdata_preg[15]}}, rdata_preg[15:8]};
                2'b10: regfilemux_out = {{24{rdata_preg[23]}}, rdata_preg[23:16]};
                2'b11: regfilemux_out = {{24{rdata_preg[31]}}, rdata_preg[31:24]};
                        endcase
            end
        regfilemux::lbu: begin
            case(addr_lsb_preg)
                2'b00: regfilemux_out = {{24{1'b0}}, rdata_preg[7:0]};
                2'b01: regfilemux_out = {{24{1'b0}}, rdata_preg[15:8]};
                2'b10: regfilemux_out = {{24{1'b0}}, rdata_preg[23:16]};
                2'b11: regfilemux_out = {{24{1'b0}}, rdata_preg[31:24]};
                        endcase
            end
        regfilemux::lh: regfilemux_out = (addr_lsb_preg[1]) ? {{16{rdata_preg[31]}}, rdata_preg[31:16]} : {{16{rdata_preg[15]}}, rdata_preg[15:0]};   
        regfilemux::lhu:regfilemux_out = (addr_lsb_preg[1]) ? {{16{1'b0}}, rdata_preg[31:16]} : {{16{1'b0}}, rdata_preg[15:0]};
        default;
    endcase
end
endmodule:writeback_stage
