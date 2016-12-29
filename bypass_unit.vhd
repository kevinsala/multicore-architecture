LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bypass_unit IS
	PORT(
		reg_src1_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_src2_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_src1_v_D      : IN STD_LOGIC;
		reg_src2_v_D      : IN STD_LOGIC;
		inm_src2_v_D      : IN STD_LOGIC;
		mem_write_D       : IN STD_LOGIC;
		reg_dest_A        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_A          : IN STD_LOGIC;
		reg_dest_L        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_L          : IN STD_LOGIC;
		reg_dest_C        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reg_we_C          : IN STD_LOGIC;
		mux_src1_D_BP     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_src2_D_BP     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_mem_data_D_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_mem_data_A_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		mux_mem_data_L_BP : OUT STD_LOGIC
	);
END bypass_unit;

ARCHITECTURE bypass_unit_behavior OF bypass_unit IS
BEGIN
	mux_src1_D_BP <= "11" WHEN (reg_src1_D = reg_dest_A AND reg_src1_v_D = '1' AND reg_we_A = '1')
			ELSE "10" WHEN (reg_src1_D = reg_dest_L AND reg_src1_v_D = '1' AND reg_we_L = '1')
			ELSE "01" WHEN (reg_src1_D = reg_dest_C AND reg_src1_v_D = '1' AND reg_we_C = '1')
			ELSE "00" WHEN (reg_src1_v_D = '1')
			ELSE "00";

	mux_src2_D_BP <= "11" WHEN (reg_src2_D = reg_dest_A AND reg_src2_v_D = '1' AND reg_we_A = '1')
			ELSE "10" WHEN (reg_src2_D = reg_dest_L AND reg_src2_v_D = '1' AND reg_we_L = '1')
			ELSE "01" WHEN (reg_src2_D = reg_dest_C AND reg_src2_v_D = '1' AND reg_we_C = '1')
			ELSE "00" WHEN (reg_src2_v_D = '1')
			ELSE "00";

	mux_mem_data_D_BP <= "11" WHEN (reg_src2_D = reg_dest_A AND reg_we_A = '1')
			ELSE "10" WHEN (reg_src2_D = reg_dest_L AND reg_we_L = '1')
			ELSE "01" WHEN (reg_src2_D = reg_dest_C AND reg_we_C = '1')
			ELSE "00";

	mux_mem_data_A_BP <= "10" WHEN (reg_dest_A = reg_dest_L AND reg_we_L = '1')
			ELSE "01" WHEN (reg_dest_A = reg_dest_C AND reg_we_C = '1')
			ELSE "00";

	mux_mem_data_L_BP <= '1' WHEN (reg_dest_L = reg_dest_C AND reg_we_C = '1')
			ELSE '0';
END bypass_unit_behavior;
