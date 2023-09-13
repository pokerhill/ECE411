simSetSimulator "-vcssv" -exec "/home/sohilp2/ECE_Final_Proj/mp4/sim/simv" -args
debImport "-dbdir" "/home/sohilp2/ECE_Final_Proj/mp4/sim/simv.daidir"
debLoadSimResult /home/sohilp2/ECE_Final_Proj/mp4/sim/dump.fsdb
wvCreateWindow
srcHBSelect "mp4_tb.dut.INSTR_DECODE.regfile" -win $_nTrace1
srcSetScope "mp4_tb.dut.INSTR_DECODE.regfile" -delim "." -win $_nTrace1
srcHBSelect "mp4_tb.dut.INSTR_DECODE.regfile" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "data" -line 13 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 439655750.090621 -snap {("G1" 1)}
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
srcHBSelect "mp4_tb.dut.INSTR_FETCH" -win $_nTrace1
srcSetScope "mp4_tb.dut.INSTR_FETCH" -delim "." -win $_nTrace1
srcHBSelect "mp4_tb.dut.INSTR_FETCH" -win $_nTrace1
srcHBSelect "mp4_tb.dut.INSTR_FETCH.BR_PREDICTOR" -win $_nTrace1
srcSetScope "mp4_tb.dut.INSTR_FETCH.BR_PREDICTOR" -delim "." -win $_nTrace1
srcHBSelect "mp4_tb.dut.INSTR_FETCH.BR_PREDICTOR" -win $_nTrace1
verdiWindowResize -win $_Verdi_1 "305" "149" "1152" "483"
debExit
