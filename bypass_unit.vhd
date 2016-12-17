LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bypass_unit IS
	PORT(
		reg_src1_A      : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_src2_A      : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_src1_v_A    : IN STD_LOGIC;
		reg_src2_v_A    : IN STD_LOGIC;
		inm_src2_v_A    : IN STD_LOGIC;
		mem_write_A     : IN STD_LOGIC;
		reg_dest_C      : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_C        : IN STD_LOGIC;
		reg_dest_W      : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_W        : IN STD_LOGIC;
		mux_src1_BP     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_src2_BP     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_mem_data_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END bypass_unit;

ARCHITECTURE bypass_unit_behavior OF bypass_unit IS
BEGIN
	mux_src1_BP <= "10" WHEN (reg_src1_A = reg_dest_C AND reg_src1_v_A = '1' AND reg_we_C = '1')
			ELSE "01" WHEN (reg_src1_A = reg_dest_W AND reg_src1_v_A = '1' AND reg_we_W = '1')
			ELSE "00" WHEN (reg_src1_v_A = '1')
			ELSE "11";

	mux_src2_BP <= "11" WHEN (inm_src2_v_A = '1')
			ELSE "10" WHEN (reg_src2_A = reg_dest_C AND reg_src2_v_A = '1' AND mem_write_A = '0' AND reg_we_C = '1')
			ELSE "01" WHEN (reg_src2_A = reg_dest_W AND reg_src2_v_A = '1' AND mem_write_A = '0' AND reg_we_W = '1')
			ELSE "00" WHEN (reg_src2_v_A = '1')
			ELSE "11";

	mux_mem_data_BP <= "10" WHEN (reg_src2_A = reg_dest_C AND reg_we_C = '1')
			ELSE "01" WHEN (reg_src2_A = reg_dest_W AND reg_we_W = '1')
			ELSE "00";
END bypass_unit_behavior;
