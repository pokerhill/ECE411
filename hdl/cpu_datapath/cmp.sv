`define BAD_MUX_SEL $display("Illegal mux select")
`define UNDEF_MUX_SEL $display("Undef behavior")

module cmp
import rv32i_types::*;
(
	input branch_funct3_t cmpop,
	input [31:0] a, b,
	output logic br_en
);

always_comb
begin
	unique case (cmpop)
		rv32i_types::beq: br_en = (a == b);
		rv32i_types::bne: br_en = (a != b);
		rv32i_types::blt: br_en = ($signed(a) < $signed(b));
		rv32i_types::bge: br_en = ($signed(a) >= $signed(b));
		rv32i_types::bltu: br_en = (a < b);
		rv32i_types::bgeu: br_en = (a >= b);
		default:; 
	endcase
end

endmodule:cmp
