LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.utils.ALL;

ENTITY branch_predictor IS
	PORT(
		clk	      : IN  STD_LOGIC;
		reset     : IN  STD_LOGIC;
		pc_F      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		next_pc_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		taken_F   : OUT STD_LOGIC;
		info_F    : OUT STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
		branch_A  : IN  STD_LOGIC;
		taken_A   : IN  STD_LOGIC;
		pc_A      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		next_pc_A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		info_A    : IN  STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
		error_A   : IN  STD_LOGIC
	);
END branch_predictor;

ARCHITECTURE branch_predictor_behaviour OF branch_predictor IS
	CONSTANT SBP_INDEX_BITS : INTEGER := SBP_ADDR_BITS;
	CONSTANT SBP_ENTRIES    : INTEGER := 2 ** SBP_INDEX_BITS;

	CONSTANT SBP_ADDR_LSB : INTEGER := 2;
	CONSTANT SBP_ADDR_MSB : INTEGER := SBP_ADDR_LSB + SBP_ADDR_BITS - 1;

	TYPE selector_fields_t IS ARRAY(SBP_ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(SBP_SLCT_BITS-1 DOWNTO 0);

	COMPONENT local_branch_predictor IS
		PORT(
			clk	      : IN  STD_LOGIC;
			reset     : IN  STD_LOGIC;
			pc_F      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			next_pc_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			taken_F   : OUT STD_LOGIC;
			info_F    : OUT STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
			branch_A  : IN  STD_LOGIC;
			taken_A   : IN  STD_LOGIC;
			pc_A      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			next_pc_A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			info_A    : IN  STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
			enable_A  : IN  STD_LOGIC
		);
	END COMPONENT;

	COMPONENT global_branch_predictor IS
		PORT(
			clk	      : IN  STD_LOGIC;
			reset     : IN  STD_LOGIC;
			pc_F      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			next_pc_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			taken_F   : OUT STD_LOGIC;
			info_F    : OUT STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
			branch_A  : IN  STD_LOGIC;
			taken_A   : IN  STD_LOGIC;
			pc_A      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			next_pc_A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			info_A    : IN  STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
			enable_A  : IN  STD_LOGIC
		);
	END COMPONENT;

	SIGNAL selector : selector_fields_t;

	SIGNAL entry_F : INTEGER RANGE 0 TO SBP_ENTRIES-1 := 0;
	SIGNAL entry_A : INTEGER RANGE 0 TO SBP_ENTRIES-1 := 0;

	SIGNAL selection_F : STD_LOGIC := '0';
	SIGNAL selection_A : STD_LOGIC := '0';

	SIGNAL next_pc_F_0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL next_pc_F_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL taken_F_0   : STD_LOGIC;
	SIGNAL taken_F_1   : STD_LOGIC;
	SIGNAL info_F_0    : STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
	SIGNAL info_F_1    : STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);

	SIGNAL enable_A_0 : STD_LOGIC;
	SIGNAL enable_A_1 : STD_LOGIC;
BEGIN
	execution_process : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) AND reset = '1' THEN
			FOR i IN 0 TO SBP_ENTRIES-1 LOOP
				selector(i) <= (OTHERS => '0');
			END LOOP;
		ELSIF falling_edge(clk) AND reset = '0' THEN
			IF branch_A = '1' THEN
				IF (selection_A XOR error_A) = '0' AND selector(entry_A) /= "00" THEN
					selector(entry_A) <= selector(entry_A) - "01";
				ELSIF (selection_A XOR error_A) = '1' AND selector(entry_A) /= "11" THEN
					selector(entry_A) <= selector(entry_A) + "01";
				END IF;
			END IF;
		END IF;
	END PROCESS execution_process;

	lbp : local_branch_predictor PORT MAP(
		clk => clk,
		reset => reset,
		pc_F => pc_F,
		next_pc_F => next_pc_F_0,
		taken_F => taken_F_0,
		info_F => info_F_0,
		branch_A => branch_A,
		taken_A => taken_A,
		pc_A => pc_A,
		next_pc_A => next_pc_A,
		info_A => info_A,
		enable_A => enable_A_0
	);

	gbp : global_branch_predictor PORT MAP(
		clk => clk,
		reset => reset,
		pc_F => pc_F,
		next_pc_F => next_pc_F_1,
		taken_F => taken_F_1,
		info_F => info_F_1,
		branch_A => branch_A,
		taken_A => taken_A,
		pc_A => pc_A,
		next_pc_A => next_pc_A,
		info_A => info_A,
		enable_A => enable_A_1
	);

	entry_F <= to_integer(unsigned(pc_F(SBP_ADDR_MSB DOWNTO SBP_ADDR_LSB)));
	entry_A <= to_integer(unsigned(pc_A(SBP_ADDR_MSB DOWNTO SBP_ADDR_LSB)));

	selection_F <= '1' WHEN (selector(entry_F) = "10" OR selector(entry_F) = "11") ELSE '0';
	selection_A <= info_A(BP_INFO_BITS-1);

	WITH selection_F SELECT next_pc_F <=
		next_pc_F_0 WHEN '0',
		next_pc_F_1 WHEN OTHERS;

	WITH selection_F SELECT taken_F <=
		taken_F_0 WHEN '0',
		taken_F_1 WHEN OTHERS;

	WITH selection_F SELECT info_F(BP_INFO_BITS-2 DOWNTO 0) <=
		info_F_0(BP_INFO_BITS-2 DOWNTO 0) WHEN '0',
		info_F_1(BP_INFO_BITS-2 DOWNTO 0) WHEN OTHERS;

	enable_A_0 <= '1' WHEN selection_A = '0' AND branch_A = '1' ELSE '0';
	enable_A_1 <= '1' WHEN selection_A = '1' AND branch_A = '1' ELSE '0';

	info_F(BP_INFO_BITS-1) <= selection_F;
END branch_predictor_behaviour;
