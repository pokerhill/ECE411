module WordGenerator
import rv32i_types::*;
(
input rv32i_opcode opcode,
input logic [2:0] funct3,
input logic [6:0] funct7,
output rv32i_control_word ctrl
);
/*
typedef struct packed {
    alu_ops aluop;
    branch_funct3_t cmpop;
    cmpmux_sel_t cmpmux_sel;
    alumux1_sel_t alumux1_sel;
    alumux2_sel_t alumux2_sel;
    regfilemux_sel_t regfilemux_sel;
    pcmux_sel_t pcmux_sel;
    logic read_mem;
    logic write_mem;
    logic write_reg;
} rv32i_control_word;
*/
arith_funct3_t arith_funct3;
branch_funct3_t branch_funct3;
load_funct3_t load_funct3;
assign arith_funct3 = arith_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);

assign ctrl.opcode = opcode;

function void setControlWord(pcmux::pcmux_sel_t pcmux_sel, branch_funct3_t cmpop,  cmpmux::cmpmux2_sel_t cmpmux2_sel, alu_ops aluop, 
                            alumux::alumux1_sel_t alumux1_sel, alumux::alumux2_sel_t alumux2_sel,
                            logic read_mem, logic write_mem, logic write_reg, regfilemux::regfilemux_sel_t regfilemux_sel);
    ctrl.aluop              = aluop;
    ctrl.cmpop              = cmpop;
    ctrl.cmpmux2_sel        = cmpmux2_sel;
    ctrl.alumux1_sel        = alumux1_sel;
    ctrl.alumux2_sel        = alumux2_sel;
    ctrl.regfilemux_sel     = regfilemux_sel;
    ctrl.pcmux_sel          = pcmux_sel;
    ctrl.read_mem           = read_mem;
    ctrl.write_mem          = write_mem;       
    ctrl.write_reg          = write_reg ;
endfunction


always_comb begin
    case(opcode)

        op_auipc: setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::pc_out, alumux::u_imm, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
        op_lui:   setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_ops'(funct3), alumux::rs1_out, alumux::u_imm, 1'b0, 1'b0, 1'b1, regfilemux::u_imm);



        op_jal:   setControlWord(pcmux::alu_out, branch_funct3, cmpmux::rs2_out, alu_add, alumux::pc_out, alumux::j_imm, 1'b0, 1'b0, 1'b1, regfilemux::pc_plus4);
        op_jalr:  setControlWord(pcmux::alu_mod2, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::i_imm, 1'b0, 1'b0, 1'b1, regfilemux::pc_plus4);



        op_br: setControlWord(pcmux::cmp_out, branch_funct3, cmpmux::rs2_out, alu_add, alumux::pc_out, alumux::b_imm, 1'b0, 1'b0,1'b0, regfilemux::alu_out);

        op_load:begin
            case(load_funct3)
                lb:  setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::i_imm, 1'b1, 1'b0, 1'b1, regfilemux::lb);
                lh:  setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::i_imm, 1'b1, 1'b0, 1'b1, regfilemux::lh);
                lw:  setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::i_imm, 1'b1, 1'b0, 1'b1, regfilemux::lw);
                lbu: setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::i_imm, 1'b1, 1'b0, 1'b1, regfilemux::lbu);
                lhu: setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::i_imm, 1'b1, 1'b0, 1'b1, regfilemux::lhu);
            endcase
            end


        op_store: begin
            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::s_imm, 1'b0, 1'b1, 1'b0, regfilemux::alu_out);
            end


        op_imm:begin
            unique case(arith_funct3)
                slt:    setControlWord(pcmux::pc_plus4, blt,  cmpmux::i_imm,  alu_sll, alumux::rs1_out, alumux::i_imm, 1'b0, 1'b0, 1'b1, regfilemux::br_en);
                sltu:   setControlWord(pcmux::pc_plus4, bltu, cmpmux::i_imm,  alu_sll, alumux::rs1_out, alumux::i_imm, 1'b0, 1'b0, 1'b1, regfilemux::br_en);
                sr:     begin 
                        if(funct7[5]) //sra case
                            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_sra, alumux::rs1_out, alumux::i_imm, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                        else
                            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_srl, alumux::rs1_out, alumux::i_imm, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                        end
                default: setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_ops'(funct3), alumux::rs1_out, alumux::i_imm, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                
            endcase
            end


        op_reg:begin
            unique case(arith_funct3)
                add:    begin 
                        if(funct7[5])
                            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_sub, alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                        else
                            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_add, alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                    end
                slt:    setControlWord(pcmux::pc_plus4, blt,  cmpmux::rs2_out,  alu_sll, alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::br_en);
                sltu:   setControlWord(pcmux::pc_plus4, bltu, cmpmux::rs2_out,  alu_sll, alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::br_en);
                sr:     begin 
                        if(funct7[5]) //sra case
                            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_sra, alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                        else
                            setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_srl, alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
                        end
                default: setControlWord(pcmux::pc_plus4, branch_funct3, cmpmux::rs2_out, alu_ops'(funct3), alumux::rs1_out, alumux::rs2_out, 1'b0, 1'b0, 1'b1, regfilemux::alu_out);
            endcase
            end
    endcase
end

endmodule: WordGenerator

