// Change frequency for accurate timing
`define FREQUENCY_MHZ 100.0
`define FREQUENCY (`FREQUENCY_MHZ * 1000000)
`define PERIOD_NS (1000000000/`FREQUENCY)
`define PERIOD_CLK (`PERIOD_NS / 2)

module forwardingunit_TB;
`timescale 1ns/1ps
import rv32i_types::*;

logic clk;
rv32i_reg  rs1_id_IdEx, rs2_id_IdEx, rs2_id_ExMem, rd_id_MemWb, rd_id_ExMem;
rv32i_control_word control_word_IdEx, control_word_ExMem, control_word_MemWb;
alumux::alumux1_sel_t alumux1_sel;
alumux::alumux2_sel_t alumux2_sel;
cachemux::cachemux_sel_t cachemux_sel;

forwardingunit fwd(.*);
int errorcnt = 0;
always #(`PERIOD_CLK) clk = clk === 1'b0;
initial begin
	//TEST CODE FOR FOWARDING PATH FROM EXMEM TO ALUINPUT
         rs1_id_IdEx = 3;
         rs2_id_IdEx =  3;
         rs2_id_ExMem = 0;
         rd_id_MemWb =  0;
         rd_id_ExMem = 3;
         control_word_ExMem = 0;
         control_word_MemWb = 0;
         control_word_IdEx = 0;
         control_word_ExMem.write_reg = 1'b1;
         #5;
         if(alumux1_sel != alumux::alu_out_ExMem1) begin
            $display("ALU1MUX: Expecected fwd from alu_out");
		errorcnt +=1;
		end
         if(alumux2_sel !=  alumux::alu_out_ExMem2) begin
            $display("ALU2MUX: Expecected fwd from alu_out");
		errorcnt +=1;
		end
         if(cachemux_sel != cachemux::rs2_out_ExMem) begin
	    $display("CAHCEMUX: Expecected no fwd");
            	errorcnt +=1;
		end
	#10;

	 //TEST CODE FOR FOWARDING PATH FROM EXMEM TO DCACHEINPUT
	 rs1_id_IdEx = 0;
         rs2_id_IdEx =  0;
         rs2_id_ExMem = 3;
         rd_id_MemWb =  3;
         rd_id_ExMem = 0;
         control_word_ExMem = 0;
         control_word_MemWb = 0;
         control_word_IdEx = 0;
	 control_word_ExMem.write_mem = 1'b1;
	 control_word_MemWb.write_reg = 1'b1;   
         #10;

         if(alumux1_sel != control_word_IdEx.alumux1_sel) begin
            $display("ALU1MUX: Expecected no fwd");
		errorcnt +=1;
		end
         if(alumux2_sel != control_word_IdEx.alumux2_sel) begin
            $display("ALU2MUX: Expecected no fwd");
		errorcnt +=1;
		end
         if(cachemux_sel != cachemux::r_data_MemWb) begin
	    $display("CAHCEMUX: Expecected fwd from r_data");
            	errorcnt +=1;
		end
	#10;


	//TESTCODE FOR THE FOWARDING PATH FROM MEM TO ALUINPUT


	











	if(errorcnt == 0)
		$display("\n\nNo errors my little POG champ :)\n\n");
		$finish;

end

endmodule : forwardingunit_TB

//module FowardingUnit();
    //input  rv32i_reg  rs1_id_IdEx, rs2_id_IdEx, rs2_id_ExMem, rd_id_MemWb, rd_id_ExMem;
    //input rv32i_control_word control_word_IdEx, control_word_ExMem, control_word_MemWb;
    //output alumux1_sel_t alumux1_sel;
    //output alumux2_sel_t alumux2_sel;
    //output cachemux_sel_t cachemux_sel



