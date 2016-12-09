LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY decode IS
	PORT (op_code : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
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
	CONSTANT OP_ADD : STD_LOGIC_VECTOR := "0000000";
	CONSTANT OP_SUB : STD_LOGIC_VECTOR := "0000001";
	CONSTANT OP_MUL : STD_LOGIC_VECTOR := "0000010";
	CONSTANT OP_LDB : STD_LOGIC_VECTOR := "0010000";
	CONSTANT OP_LDW : STD_LOGIC_VECTOR := "0010001";
	CONSTANT OP_STB : STD_LOGIC_VECTOR := "0010010";
	CONSTANT OP_STW : STD_LOGIC_VECTOR := "0010011";
	CONSTANT OP_MOV : STD_LOGIC_VECTOR := "0010100";
	CONSTANT OP_BEQ : STD_LOGIC_VECTOR := "0110000";
	CONSTANT OP_JMP : STD_LOGIC_VECTOR := "0110001";
	CONSTANT OP_NOP : STD_LOGIC_VECTOR := "1111111";

	SIGNAL op_code_int : STD_LOGIC_VECTOR(6 DOWNTO 0);
BEGIN
	op_code_int <= op_code;

	WITH op_code_int SELECT branch <=
		'1' WHEN OP_BEQ,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT jump <=
		'1' WHEN OP_JMP,
		'0' WHEN OTHERS;

	WITH op_code_int SELECT reg_src1_v <=
		'1' WHEN OTHERS;

	WITH op_code_int SELECT reg_src2_v <=
		'1' WHEN OP_ADD,
		'1' WHEN OP_SUB,
		'1' WHEN OP_MUL,
		'1' WHEN OP_NOP, -- TODO: !?
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
		'1' WHEN OP_MOV,
		'0' WHEN OTHERS;

END structure;

