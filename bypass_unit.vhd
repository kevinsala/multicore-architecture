LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.utils.ALL;

ENTITY bypass_unit IS
	PORT(
		reg_src1_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_src2_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_src1_v_D      : IN STD_LOGIC;
		reg_src2_v_D      : IN STD_LOGIC;
		inm_src2_v_D      : IN STD_LOGIC;
		reg_dest_A        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_A          : IN STD_LOGIC;
		reg_dest_C        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_C          : IN STD_LOGIC;
		reg_dest_M5       : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_M5		  : IN STD_LOGIC;
		reg_src1_D_p_ROB  : IN STD_LOGIC;
		reg_src1_D_inst_type_ROB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		reg_src2_D_p_ROB  : IN STD_LOGIC;
		reg_src2_D_inst_type_ROB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		mux_src1_D_BP     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		mux_src2_D_BP     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		mux_mem_data_D_BP : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		mux_mem_data_A_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END bypass_unit;

ARCHITECTURE bypass_unit_behavior OF bypass_unit IS
BEGIN
	mux_src1_D_BP <= "001" WHEN (reg_src1_D = reg_dest_A AND reg_src1_v_D = '1' AND reg_we_A = '1')
			ELSE "100" WHEN (reg_src1_D_inst_type_ROB = INST_TYPE_ALU AND reg_src1_D_p_ROB = '1')
			ELSE "010" WHEN (reg_src1_D = reg_dest_C AND reg_src1_v_D = '1' AND reg_we_C = '1')
			ELSE "100" WHEN (reg_src1_D_inst_type_ROB = INST_TYPE_MEM AND reg_src1_D_p_ROB = '1')
			ELSE "011" WHEN (reg_src1_D = reg_dest_M5 AND reg_src1_v_D = '1' AND reg_we_M5 = '1')
			ELSE "100" WHEN (reg_src1_D_inst_type_ROB = INST_TYPE_MUL AND reg_src1_D_p_ROB = '1')
			ELSE "000";

	mux_src2_D_BP <= "001" WHEN (reg_src2_D = reg_dest_A AND reg_src1_v_D = '1' AND reg_we_A = '1')
			ELSE "100" WHEN (reg_src2_D_inst_type_ROB = INST_TYPE_ALU AND reg_src2_D_p_ROB = '1')
			ELSE "010" WHEN (reg_src2_D = reg_dest_C AND reg_src2_v_D = '1' AND reg_we_C = '1')
			ELSE "100" WHEN (reg_src2_D_inst_type_ROB = INST_TYPE_MEM AND reg_src2_D_p_ROB = '1')
			ELSE "011" WHEN (reg_src2_D = reg_dest_M5 AND reg_src2_v_D = '1' AND reg_we_M5 = '1')
			ELSE "100" WHEN (reg_src2_D_inst_type_ROB = INST_TYPE_MUL AND reg_src2_D_p_ROB = '1')
			ELSE "000";

	mux_mem_data_D_BP <= "001" WHEN (reg_src2_D = reg_dest_A AND reg_src1_v_D = '1' AND reg_we_A = '1')
			ELSE "100" WHEN (reg_src2_D_inst_type_ROB = INST_TYPE_ALU AND reg_src2_D_p_ROB = '1')
			ELSE "010" WHEN (reg_src2_D = reg_dest_C AND reg_src2_v_D = '1' AND reg_we_C = '1')
			ELSE "100" WHEN (reg_src2_D_inst_type_ROB = INST_TYPE_MEM AND reg_src2_D_p_ROB = '1')
			ELSE "011" WHEN (reg_src2_D = reg_dest_M5 AND reg_src2_v_D = '1' AND reg_we_M5 = '1')
			ELSE "100" WHEN (reg_src2_D_inst_type_ROB = INST_TYPE_MUL AND reg_src2_D_p_ROB = '1')
			ELSE "000";

	mux_mem_data_A_BP <= "01" WHEN (reg_dest_A = reg_dest_C AND reg_we_C = '1')
			ELSE "11" WHEN (reg_dest_A = reg_dest_M5 AND reg_we_M5 = '1')
			ELSE "00";
END bypass_unit_behavior;
