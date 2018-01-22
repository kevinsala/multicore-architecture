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
		info_A    : IN  STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0)
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
			info_A    : IN  STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL selector : selector_fields_t;

	SIGNAL entry_F : INTEGER RANGE 0 TO SBP_ENTRIES-1 := 0;
	SIGNAL entry_A : INTEGER RANGE 0 TO SBP_ENTRIES-1 := 0;

	SIGNAL selection_F : STD_LOGIC := '0';
	SIGNAL selection_A : STD_LOGIC := '0';
BEGIN
	execution_process : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) AND reset = '1' THEN
			FOR i IN 0 TO SBP_ENTRIES-1 LOOP
				selector(i) <= (OTHERS => '0');
			END LOOP;
		ELSE
			-- TODO: Implement selection update
		END IF;
	END PROCESS execution_process;

	lbp : local_branch_predictor PORT MAP(
		clk => clk,
		reset => reset,
		pc_F => pc_F,
		next_pc_F => next_pc_F,
		taken_F => taken_F,
		info_F => info_F,
		branch_A => branch_A,
		taken_A => taken_A,
		pc_A => pc_A,
		next_pc_A => next_pc_A,
		info_A => info_A
	);

	entry_F <= to_integer(unsigned(pc_F(SBP_ADDR_MSB DOWNTO SBP_ADDR_LSB)));
	entry_A <= to_integer(unsigned(pc_A(SBP_ADDR_MSB DOWNTO SBP_ADDR_LSB)));

	selection_F <= '1' WHEN (selector(entry_F) = "10" OR selector(entry_F) = "11") ELSE '0';
	selection_A <= info_A(BP_INFO_BITS-1);
END branch_predictor_behaviour;
