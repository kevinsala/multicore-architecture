LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY decode IS
	PORT (
		inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		op_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		reg_src1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		calc_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		branch : OUT STD_LOGIC;
		jump : OUT STD_LOGIC;
		reg_src1_v : OUT STD_LOGIC;
		reg_src2_v : OUT STD_LOGIC;
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

	calc_addr <= pc + (inm_ext_int(29 DOWNTO 0) & "00");

	op_code <= op_code_int;
	reg_src1 <= inst(19 DOWNTO 15);
	reg_dest <= inst(24 DOWNTO 20);

	WITH op_code_int SELECT reg_src2 <=
		inst(24 DOWNTO 20) WHEN OP_STW,
		inst(24 DOWNTO 20) WHEN OP_STB,
		inst(14 DOWNTO 10) WHEN OTHERS;

	WITH op_code_INT SELECT ALU_ctrl <=
		"000" WHEN OP_ADD,
		"001" WHEN OP_SUB,
		"100" WHEN OP_LI,
		"000" WHEN OTHERS;

	-- Control signals
	WITH op_code_int SELECT branch <=
		'1' WHEN OP_BEQ,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT jump <=
		'1' WHEN OP_JMP,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT reg_src1_v <=
		'0' WHEN OP_LI,
		'1' WHEN OTHERS;

	WITH op_code_int SELECT reg_src2_v <=
		'1' WHEN OP_ADD,
		'1' WHEN OP_SUB,
		'1' WHEN OP_MUL,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT mul <=
		'1' WHEN OP_MUL,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT mem_write <=
		'1' WHEN OP_STW,
		'1' WHEN OP_STB,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT byte <=
		'1' WHEN OP_LDB,
		'1' WHEN OP_STB,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT mem_read <=
		'1' WHEN OP_LDW,
		'1' WHEN OP_LDB,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT mem_to_reg <=
		'1' WHEN OP_LDW,
		'1' WHEN OP_LDB,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT reg_we <=
		'1' WHEN OP_ADD,
		'1' WHEN OP_SUB,
		'1' WHEN OP_MUL,
		'1' WHEN OP_LDW,
		'1' WHEN OP_LDB,
		'1' WHEN OP_LI,
		'1' WHEN OP_MOV,
		'0' WHEN OTHERS;

END structure;

