LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.UTILS.ALL;

ENTITY detention_unit IS
	PORT(
		reset          : IN STD_LOGIC;
		inst_type_D    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		reg_src1_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src1_v_D   : IN STD_LOGIC;
		reg_src2_v_D   : IN STD_LOGIC;
		mem_we_D	   : IN STD_LOGIC;
		branch_taken_A : IN STD_LOGIC;
		mul_M1 			: IN STD_LOGIC;
		mul_M2 			: IN STD_LOGIC;
		reg_dest_M2		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mul_M3 			: IN STD_LOGIC;
		reg_dest_M3		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mul_M4 			: IN STD_LOGIC;
		reg_dest_M4		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mul_M5			: IN STD_LOGIC;
		reg_dest_M5		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		inst_type_A	   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		reg_dest_A     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_we_A       : IN STD_LOGIC;
		mem_read_A     : IN STD_LOGIC;
		reg_dest_C     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mem_read_C     : IN STD_LOGIC;
		done_F         : IN STD_LOGIC;
		done_C         : IN STD_LOGIC;
		exc_D          : IN STD_LOGIC;
		exc_A          : IN STD_LOGIC;
		exc_C          : IN STD_LOGIC;
		conflict       : OUT STD_LOGIC;
		reg_PC_reset   : OUT STD_LOGIC;
		reg_F_D_reset  : OUT STD_LOGIC;
		reg_D_A_reset  : OUT STD_LOGIC;
		reg_A_C_reset  : OUT STD_LOGIC;
		reg_PC_we      : OUT STD_LOGIC;
		reg_F_D_we     : OUT STD_LOGIC;
		reg_D_A_we     : OUT STD_LOGIC;
		reg_A_C_we     : OUT STD_LOGIC;
		rob_count      : OUT STD_LOGIC;
		rob_rollback   : OUT STD_LOGIC
	);
END detention_unit;

ARCHITECTURE detention_unit_behavior OF detention_unit IS

	-- Determine that there are no conflicts
	SIGNAL conflict_ALU : STD_LOGIC;
	SIGNAL conflict_MUL : STD_LOGIC; -- Detener instrucciones porque la inst MUL está en M1 o en M2
	SIGNAL conflict_MUL_ALU : STD_LOGIC; -- Detener instrucciones alu-dependientes de una inst. mul
	SIGNAL conflict_MUL_M1 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_MUL_M2 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_MUL_M3 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_MUL_M4 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_i : STD_LOGIC;
	SIGNAL conflict_MEM_dep : STD_LOGIC;
	SIGNAL conflict_MEM : STD_LOGIC;
BEGIN
	conflict_ALU <= '1' WHEN mem_read_A = '1' AND done_C = '1' AND ((reg_src1_D = reg_dest_A AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_A AND reg_src2_v_D = '1' AND NOT mem_we_D = '1')) ELSE '0';
	conflict_MUL_M1 <= '1' WHEN  mul_M1 = '1' AND ((reg_src1_D = reg_dest_A AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_A AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MUL_M2 <= '1' WHEN  mul_M2 = '1' AND ((reg_src1_D = reg_dest_M2 AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_M2 AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MUL_M3 <= '1' WHEN  mul_M3 = '1' AND ((reg_src1_D = reg_dest_M3 AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_M3 AND reg_src2_v_D = '1' AND NOT mem_we_D = '1')) ELSE '0';
	conflict_MUL_M4 <= '1' WHEN  mul_M4 = '1' AND ((reg_src1_D = reg_dest_M4 AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_M4 AND reg_src2_v_D = '1' AND NOT mem_we_D = '1')) ELSE '0';

	conflict_MUL_ALU <= conflict_MUL_M1 OR conflict_MUL_M2 OR conflict_MUL_M3 OR conflict_MUL_M4;

	conflict_i <= conflict_ALU OR conflict_MUL_ALU;

	conflict_MEM_dep <= '1' WHEN mem_read_C = '1' AND ((reg_src1_D = reg_dest_C AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_C AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MEM <= NOT done_C AND (conflict_MEM_dep OR to_std_logic(inst_type_A = INST_TYPE_MEM));

	reg_PC_we <= NOT conflict_i AND done_F AND NOT conflict_MEM;
	rob_count <= NOT conflict_i AND done_F AND NOT conflict_MEM;
	rob_rollback <= branch_taken_A AND NOT to_std_logic(inst_type_D = INST_TYPE_NOP); -- Don't decrease the ROB counter if the instruction just after the branch was a iCache miss
	reg_F_D_we <= NOT conflict_i AND NOT conflict_MEM;
	reg_D_A_we <= NOT conflict_MEM;
	reg_A_C_we <= done_C;

	reg_PC_reset <= reset;
	reg_F_D_reset <= reset OR branch_taken_A OR (NOT done_F AND NOT conflict_MEM AND NOT conflict_i) OR exc_D OR exc_A OR exc_C;
	reg_D_A_reset <= reset OR branch_taken_A OR conflict_i OR exc_A OR exc_C;
	reg_A_C_reset <= reset OR (done_C AND to_std_logic(inst_type_A /= INST_TYPE_MEM)) OR exc_C;

	conflict <= conflict_i;
END detention_unit_behavior;
