LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.utils.ALL;

ENTITY decode IS
	PORT (
		inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		inst_v : IN STD_LOGIC;
		pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status : IN STD_LOGIC;
		inst_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		op_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		reg_src1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		branch : OUT STD_LOGIC;
		branch_if_eq : OUT STD_LOGIC;
		jump : OUT STD_LOGIC;
		reg_src1_v : OUT STD_LOGIC;
		reg_src2_v : OUT STD_LOGIC;
		inm_src2_v : OUT STD_LOGIC;
		mem_write : OUT STD_LOGIC;
		byte : OUT STD_LOGIC;
		mem_read : OUT STD_LOGIC;
		reg_we : OUT STD_LOGIC;
		iret : OUT STD_LOGIC;
		invalid_inst : OUT STD_LOGIC
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
	CONSTANT OP_BNE : STD_LOGIC_VECTOR := "0110010";
	CONSTANT OP_JMP : STD_LOGIC_VECTOR := "0110001";
	CONSTANT OP_IRET : STD_LOGIC_VECTOR := "0110101";
	CONSTANT OP_NOP : STD_LOGIC_VECTOR := "1111111";

	SIGNAL op_code_int : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL inm_ext_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL offset_low : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL reg_dest_int : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src1_int : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src2_int : STD_LOGIC_VECTOR(4 DOWNTO 0);

	SIGNAL reg_src1_v_int : STD_LOGIC;
	SIGNAL reg_src2_v_int : STD_LOGIC;
	SIGNAL reg_we_int : STD_LOGIC;

	SIGNAL alu_inst : STD_LOGIC;
	SIGNAL mem_inst : STD_LOGIC;
	SIGNAL mul_inst : STD_LOGIC;

	SIGNAL priv_inst : STD_LOGIC;
	SIGNAL invalid_dest : STD_LOGIC;
	SIGNAL invalid_src1 : STD_LOGIC;
	SIGNAL invalid_src2 : STD_LOGIC;
BEGIN
	op_code_int <= inst(31 DOWNTO 25);

	offset_low <= inst(9 DOWNTO 0);

	-- Instruction parts
	ext : sign_ext PORT MAP(
		inst => inst,
		inm_ext => inm_ext_int
	);

	inm_ext <= inm_ext_int;

	op_code <= op_code_int;
	reg_src1_int <= inst(19 DOWNTO 15);
	reg_src1 <= reg_src1_int;

	reg_dest_int <= inst(24 DOWNTO 20);
	reg_dest <= reg_dest_int;

	reg_src2_int <= inst(24 DOWNTO 20) WHEN op_code_int = OP_STW OR op_code_int = OP_STB ELSE
					inst(14 DOWNTO 10);
	reg_src2 <= reg_src2_int;

	ALU_ctrl <= "000" WHEN op_code_int = OP_ADD ELSE
				"001" WHEN op_code_int = OP_SUB ELSE
				"100" WHEN op_code_int = OP_LI ELSE
				"101" WHEN op_code_int = OP_BEQ OR op_code_int = OP_BNE OR op_code_int = OP_JMP ELSE
				"000";

	-- Control signals
	branch <= to_std_logic(op_code_int = OP_BEQ OR op_code_int = OP_BNE);
	branch_if_eq <= to_std_logic(op_code_int = OP_BEQ);
	jump <= to_std_logic(op_code_int = OP_JMP);

	reg_src1_v_int <= NOT to_std_logic(op_code_int = OP_LI OR op_code_int = OP_NOP);
	reg_src1_v <= reg_src1_v_int;

	reg_src2_v_int <= to_std_logic(op_code_int = OP_ADD OR op_code_int = OP_SUB OR
							op_code_int = OP_MUL OR op_code_int = OP_BEQ OR
							op_code_int = OP_BNE OR op_code_int = OP_JMP OR
							op_code_int = OP_STW OR op_code_int = OP_STB);
	reg_src2_v <= reg_src2_v_int;

	inm_src2_v <= to_std_logic(op_code_int = OP_LI OR op_code_int = OP_STW OR
							op_code_int = OP_STB OR op_code_int = OP_LDW OR
							op_code_int = OP_LDB OR op_code_int = OP_BEQ OR
							op_code_int = OP_BNE OR op_code_int = OP_JMP);

	alu_inst <= to_std_logic(op_code_int = OP_ADD OR op_code_int = OP_SUB OR
								op_code_int = OP_LI OR op_code_int = OP_MOV OR
								op_code_int = OP_BEQ OR op_code_int = OP_BNE OR
								op_code_int = OP_JMP OR op_code_int = OP_IRET OR
								op_code_int = OP_NOP);
	mem_inst <= to_std_logic(op_code_int = OP_LDB OR op_code_int = OP_LDW OR
								op_code_int = OP_STB OR op_code_int = OP_STW);
	mul_inst <= to_std_logic(op_code_int = OP_MUL);

	mem_write <= to_std_logic(op_code_int = OP_STW OR op_code_int = OP_STB);
	byte <= to_std_logic(op_code_int = OP_LDB OR op_code_int = OP_STB);
	mem_read <= to_std_logic(op_code_int = OP_LDW OR op_code_int = OP_LDB);

	reg_we_int <= to_std_logic(op_code_int = OP_ADD OR op_code_int = OP_SUB OR
							op_code_int = OP_MUL OR op_code_int = OP_LDW OR
							op_code_int = OP_LDB OR op_code_int = OP_LI OR
							op_code_int = OP_MOV);
	reg_we <= reg_we_int;

	iret <= to_std_logic(op_code_int = OP_IRET);

	invalid_dest <= to_std_logic(reg_dest_int = REG_EXC_CODE OR reg_dest_int = REG_EXC_DATA) AND reg_we_int;
	invalid_src1 <= to_std_logic(reg_src1_int = REG_EXC_CODE OR reg_src1_int = REG_EXC_DATA) AND
								reg_src1_v_int AND NOT priv_status;
	invalid_src2 <=  to_std_logic(reg_src2_int = REG_EXC_CODE OR reg_src2_int = REG_EXC_DATA) AND
								reg_src2_v_int AND NOT priv_status;
	priv_inst <= to_std_logic(op_code_int = OP_IRET);

	invalid_inst <= NOT (alu_inst OR mem_inst OR mul_inst) OR
					(priv_inst AND NOT priv_status) OR
					invalid_dest OR invalid_src1 OR invalid_src2;

	inst_type <= INST_TYPE_NOP WHEN inst_v = '0'
					ELSE INST_TYPE_ALU WHEN alu_inst = '1'
					ELSE INST_TYPE_MEM WHEN mem_inst = '1'
					ELSE INST_TYPE_MUL WHEN mul_inst = '1';

END structure;

