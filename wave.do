onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/uut/clk
add wave -noupdate /testbench/uut/reset
add wave -noupdate -radix hexadecimal -childformat {{/testbench/uut/output(31) -radix hexadecimal} {/testbench/uut/output(30) -radix hexadecimal} {/testbench/uut/output(29) -radix hexadecimal} {/testbench/uut/output(28) -radix hexadecimal} {/testbench/uut/output(27) -radix hexadecimal} {/testbench/uut/output(26) -radix hexadecimal} {/testbench/uut/output(25) -radix hexadecimal} {/testbench/uut/output(24) -radix hexadecimal} {/testbench/uut/output(23) -radix hexadecimal} {/testbench/uut/output(22) -radix hexadecimal} {/testbench/uut/output(21) -radix hexadecimal} {/testbench/uut/output(20) -radix hexadecimal} {/testbench/uut/output(19) -radix hexadecimal} {/testbench/uut/output(18) -radix hexadecimal} {/testbench/uut/output(17) -radix hexadecimal} {/testbench/uut/output(16) -radix hexadecimal} {/testbench/uut/output(15) -radix hexadecimal} {/testbench/uut/output(14) -radix hexadecimal} {/testbench/uut/output(13) -radix hexadecimal} {/testbench/uut/output(12) -radix hexadecimal} {/testbench/uut/output(11) -radix hexadecimal} {/testbench/uut/output(10) -radix hexadecimal} {/testbench/uut/output(9) -radix hexadecimal} {/testbench/uut/output(8) -radix hexadecimal} {/testbench/uut/output(7) -radix hexadecimal} {/testbench/uut/output(6) -radix hexadecimal} {/testbench/uut/output(5) -radix hexadecimal} {/testbench/uut/output(4) -radix hexadecimal} {/testbench/uut/output(3) -radix hexadecimal} {/testbench/uut/output(2) -radix hexadecimal} {/testbench/uut/output(1) -radix hexadecimal} {/testbench/uut/output(0) -radix hexadecimal}} -subitemconfig {/testbench/uut/output(31) {-radix hexadecimal} /testbench/uut/output(30) {-radix hexadecimal} /testbench/uut/output(29) {-radix hexadecimal} /testbench/uut/output(28) {-radix hexadecimal} /testbench/uut/output(27) {-radix hexadecimal} /testbench/uut/output(26) {-radix hexadecimal} /testbench/uut/output(25) {-radix hexadecimal} /testbench/uut/output(24) {-radix hexadecimal} /testbench/uut/output(23) {-radix hexadecimal} /testbench/uut/output(22) {-radix hexadecimal} /testbench/uut/output(21) {-radix hexadecimal} /testbench/uut/output(20) {-radix hexadecimal} /testbench/uut/output(19) {-radix hexadecimal} /testbench/uut/output(18) {-radix hexadecimal} /testbench/uut/output(17) {-radix hexadecimal} /testbench/uut/output(16) {-radix hexadecimal} /testbench/uut/output(15) {-radix hexadecimal} /testbench/uut/output(14) {-radix hexadecimal} /testbench/uut/output(13) {-radix hexadecimal} /testbench/uut/output(12) {-radix hexadecimal} /testbench/uut/output(11) {-radix hexadecimal} /testbench/uut/output(10) {-radix hexadecimal} /testbench/uut/output(9) {-radix hexadecimal} /testbench/uut/output(8) {-radix hexadecimal} /testbench/uut/output(7) {-radix hexadecimal} /testbench/uut/output(6) {-radix hexadecimal} /testbench/uut/output(5) {-radix hexadecimal} /testbench/uut/output(4) {-radix hexadecimal} /testbench/uut/output(3) {-radix hexadecimal} /testbench/uut/output(2) {-radix hexadecimal} /testbench/uut/output(1) {-radix hexadecimal} /testbench/uut/output(0) {-radix hexadecimal}} /testbench/uut/output
add wave -noupdate /testbench/uut/load_PC
add wave -noupdate /testbench/uut/PCSrc
add wave -noupdate /testbench/uut/RegWrite_ID
add wave -noupdate /testbench/uut/RegWrite_EX
add wave -noupdate /testbench/uut/RegWrite_MEM
add wave -noupdate /testbench/uut/RegWrite_WB
add wave -noupdate /testbench/uut/Z
add wave -noupdate /testbench/uut/Branch
add wave -noupdate /testbench/uut/RegDst_ID
add wave -noupdate /testbench/uut/RegDst_EX
add wave -noupdate /testbench/uut/ALUSrc_A_ID
add wave -noupdate /testbench/uut/ALUSrc_B_ID
add wave -noupdate /testbench/uut/ALUSrc_A_EX
add wave -noupdate /testbench/uut/ALUSrc_B_EX
add wave -noupdate /testbench/uut/MemtoReg_ID
add wave -noupdate /testbench/uut/MemtoReg_EX
add wave -noupdate /testbench/uut/MemtoReg_MEM
add wave -noupdate /testbench/uut/MemtoReg_WB
add wave -noupdate /testbench/uut/MemWrite_ID
add wave -noupdate /testbench/uut/MemWrite_EX
add wave -noupdate /testbench/uut/MemWrite_MEM
add wave -noupdate /testbench/uut/MemRead_ID
add wave -noupdate /testbench/uut/MemRead_EX
add wave -noupdate /testbench/uut/MemRead_MEM
add wave -noupdate /testbench/uut/Reg_Dst_UD
add wave -noupdate /testbench/uut/Reg_Write_UD
add wave -noupdate /testbench/uut/Mem_Read_UD
add wave -noupdate /testbench/uut/Mem_Write_UD
add wave -noupdate /testbench/uut/MemtoReg_UD
add wave -noupdate /testbench/uut/ALU_Src_A_UD
add wave -noupdate /testbench/uut/ALU_Src_B_UD
add wave -noupdate /testbench/uut/switch_ctrl
add wave -noupdate /testbench/uut/ID_Write
add wave -noupdate -radix hexadecimal /testbench/uut/PC_in
add wave -noupdate -radix hexadecimal /testbench/uut/PC_out
add wave -noupdate -radix decimal /testbench/uut/four
add wave -noupdate -radix hexadecimal /testbench/uut/PC4
add wave -noupdate -radix hexadecimal /testbench/uut/DirSalto
add wave -noupdate -radix hexadecimal /testbench/uut/IR_in
add wave -noupdate -radix hexadecimal /testbench/uut/IR_ID
add wave -noupdate -radix hexadecimal /testbench/uut/PC4_ID
add wave -noupdate -radix hexadecimal /testbench/uut/inm_ext_EX
add wave -noupdate /testbench/uut/Mux_out
add wave -noupdate -radix hexadecimal /testbench/uut/inm_ext
add wave -noupdate -radix hexadecimal /testbench/uut/inm_ext_x4
add wave -noupdate -radix hexadecimal /testbench/uut/BusW
add wave -noupdate -radix hexadecimal /testbench/uut/BusA
add wave -noupdate -radix hexadecimal /testbench/uut/BusB
add wave -noupdate -radix hexadecimal /testbench/uut/BusA_EX
add wave -noupdate -radix hexadecimal /testbench/uut/BusB_EX
add wave -noupdate -radix hexadecimal /testbench/uut/BusB_MEM
add wave -noupdate -radix hexadecimal /testbench/uut/ALU_out_EX
add wave -noupdate -radix hexadecimal /testbench/uut/ALU_out_MEM
add wave -noupdate -radix hexadecimal /testbench/uut/ALU_out_WB
add wave -noupdate -radix hexadecimal /testbench/uut/Mem_out
add wave -noupdate -radix hexadecimal /testbench/uut/MDR
add wave -noupdate -radix hexadecimal /testbench/uut/Mux_ant_A_out
add wave -noupdate -radix hexadecimal /testbench/uut/Mux_ant_B_out
add wave -noupdate -radix hexadecimal /testbench/uut/Mux_ant_C_out
add wave -noupdate -radix decimal /testbench/uut/RW_EX
add wave -noupdate -radix decimal /testbench/uut/RW_MEM
add wave -noupdate -radix decimal /testbench/uut/RW_WB
add wave -noupdate -radix hexadecimal /testbench/uut/Reg_Rd_EX
add wave -noupdate -radix hexadecimal /testbench/uut/Reg_Rt_EX
add wave -noupdate -radix decimal /testbench/uut/Reg_Rs_EX
add wave -noupdate /testbench/uut/ALUctrl_ID
add wave -noupdate /testbench/uut/ALUctrl_EX
add wave -noupdate /testbench/uut/Mux_ant_A
add wave -noupdate /testbench/uut/Mux_ant_B
add wave -noupdate /testbench/uut/Mux_ant_C
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47413 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 238
configure wave -valuecolwidth 204
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4691 ps} {51667 ps}
