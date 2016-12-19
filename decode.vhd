LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.utils.ALL;

ENTITY decode IS
	PORT (
		inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		op_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		reg_src1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		jump_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		branch : OUT STD_LOGIC;
		jump : OUT STD_LOGIC;
		reg_src1_v : OUT STD_LOGIC;
		reg_src2_v : OUT STD_LOGIC;
		inm_src2_v : OUT STD_LOGIC;
		mul : OUT STD_LOGIC;
		mem_write : OUT STD_LOGIC;
		byte : OUT STD_LOGIC;
		mem_read : OUT STD_LOGIC;
		mem_to_reg : OUT STD_LOGIC;
		reg_we : OUT STD_LOGIC
	);
END decode;

ARCHITECTURE structure OF decode IS
	COMPONENT sign_ext IS
		PORT(
			inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	CONSTANT OP_ADD : STD_LOGIC_VECTOR := "0000000";
	CONSTANT OP_SUB : STD_LOGIC_VECTOR := "0000001";
	CONSTANT OP_MUL : STD_LOGIC_VECTOR := "0000010";
	CONSTANT OP_LDB : STD_LOGIC_VECTOR := "0010000";
	CONSTANT OP_LDW : STD_LOGIC_VECTOR := "0010001";
	CONSTANT OP_LI  : STD_LOGIC_VECTOR := "0001111";
	CONSTANT OP_STB : STD_LOGIC_VECTOR := "0010010";
	CONSTANT OP_STW : STD_LOGIC_VECTOR := "0010011";
	CONSTANT OP_MOV : STD_LOGIC_VECTOR := "0010100";
	CONSTANT OP_BEQ : STD_LOGIC_VECTOR := "0110000";
	CONSTANT OP_JMP : STD_LOGIC_VECTOR := "0110001";
	CONSTANT OP_NOP : STD_LOGIC_VECTOR := "1111111";

	SIGNAL op_code_int : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL inm_ext_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	op_code_int <= inst(31 DOWNTO 25);

	-- Instruction parts
	ext : sign_ext PORT MAP(
		inst => inst,
		inm_ext => inm_ext_int
	);

	inm_ext <= inm_ext_int;

	jump_addr <= pc + (inm_ext_int(29 DOWNTO 0) & "00");

	op_code <= op_code_int;
	reg_src1 <= inst(19 DOWNTO 15);
	reg_dest <= inst(24 DOWNTO 20);

	reg_src2 <= inst(24 DOWNTO 20) WHEN op_code_int = OP_STW OR op_code_int = OP_STB ELSE
				inst(14 DOWNTO 10);

	ALU_ctrl <= "000" WHEN op_code_int = OP_ADD ELSE
				"001" WHEN op_code_int = OP_SUB ELSE
				"100" WHEN op_code_int = OP_LI ELSE
				"000";

	-- Control signals
	branch <= to_std_logic(op_code_int = OP_BEQ);
	jump <= to_std_logic(op_code_int = OP_JMP);
	reg_src1_v <= NOT to_std_logic(op_code_int = OP_LI OR op_code_int = OP_NOP);
	reg_src2_v <= to_std_logic(op_code_int = OP_ADD OR op_code_int = OP_SUB OR
								op_code_int = OP_MUL);
	inm_src2_v <= to_std_logic(op_code_int = OP_STW OR op_code_int = OP_STB OR
								op_code_int = OP_LDW OR op_code_int = OP_LDB);
	mul <= to_std_logic(op_code_int = OP_MUL);
	mem_write <= to_std_logic(op_code_int = OP_STW OR op_code_int = OP_STB);
	byte <= to_std_logic(op_code_int = OP_LDB OR op_code_int = OP_STB);
	mem_read <= to_std_logic(op_code_int = OP_LDW OR op_code_int = OP_LDB);
	mem_to_reg <= to_std_logic(op_code_int = OP_LDW OR op_code_int = OP_LDB);
	reg_we <= to_std_logic(op_code_int = OP_ADD OR op_code_int = OP_SUB OR
							op_code_int = OP_MUL OR op_code_int = OP_LDW OR
							op_code_int = OP_LDB OR op_code_int = OP_LI OR
							op_code_int = OP_MOV);

END structure;

