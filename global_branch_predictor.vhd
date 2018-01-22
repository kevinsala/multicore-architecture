LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.utils.ALL;

ENTITY global_branch_predictor IS
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
END global_branch_predictor;

ARCHITECTURE global_branch_predictor_behaviour OF global_branch_predictor IS
	CONSTANT GBP_INDEX_BITS : INTEGER := GBP_ADDR_BITS + GBP_HIST_BITS;
	CONSTANT GBP_ENTRIES    : INTEGER := 2 ** GBP_INDEX_BITS;

	CONSTANT GBP_ADDR_LSB : INTEGER := 2;
	CONSTANT GBP_ADDR_MSB : INTEGER := GBP_ADDR_LSB + GBP_ADDR_BITS - 1;

	TYPE pc_fields_t      IS ARRAY(GBP_ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE taken_fields_t   IS ARRAY(GBP_ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR( 1 DOWNTO 0);
	TYPE next_pc_fields_t IS ARRAY(GBP_ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL history : STD_LOGIC_VECTOR(GBP_HIST_BITS-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL pc      : pc_fields_t;
	SIGNAL taken   : taken_fields_t;
	SIGNAL next_pc : next_pc_fields_t;

	SIGNAL entry_F   : INTEGER RANGE 0 TO GBP_ENTRIES-1 := 0;
	SIGNAL entry_A   : INTEGER RANGE 0 TO GBP_ENTRIES-1 := 0;
	SIGNAL entry_F_v : STD_LOGIC_VECTOR(GBP_INDEX_BITS-1 DOWNTO 0);
	SIGNAL entry_A_v : STD_LOGIC_VECTOR(GBP_INDEX_BITS-1 DOWNTO 0);
BEGIN
	execution_process : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) AND reset = '1' THEN
			FOR i IN 0 TO GBP_ENTRIES-1 LOOP
				pc(i) <= (OTHERS => '0');
				taken(i) <= (OTHERS => '0');
			END LOOP;
			history <= (OTHERS => '0');
		ELSIF falling_edge(clk) AND reset = '0' THEN
			IF branch_A = '1' THEN
				IF enable_A = '1' THEN
					IF pc(entry_A) = pc_A THEN
						IF taken_A = '1' AND taken(entry_A) /= "11" THEN
							taken(entry_A) <= taken(entry_A) + "01";
						ELSIF taken_A = '0' AND taken(entry_A) /= "00" THEN
							taken(entry_A) <= taken(entry_A) - "01";
						END IF;
					ELSE
						pc(entry_A) <= pc_A;
						next_pc(entry_A) <= next_pc_A;
						taken(entry_A) <= (OTHERS => '0');
						taken(entry_A)(0) <= taken_A;
					END IF;
				END IF;

				history <= to_stdlogicvector(to_bitvector(history) SLL 1);
				history(0) <= taken_A;
			END IF;
		END IF;
	END PROCESS execution_process;

	entry_F_v <= history(GBP_HIST_BITS-1 DOWNTO 0) & pc_F(GBP_ADDR_MSB DOWNTO GBP_ADDR_LSB);
	entry_F <= to_integer(unsigned(entry_F_v));
	entry_A <= to_integer(unsigned(info_A(GBP_INFO_BITS-1 DOWNTO 0)));

	info_F(GBP_INFO_BITS-1 DOWNTO 0) <= std_logic_vector(to_unsigned(entry_F, GBP_INFO_BITS));
	taken_F <= '1' WHEN (taken(entry_F) = "10" OR taken(entry_F) = "11") AND pc(entry_F) = pc_F ELSE '0';
	next_pc_F <= next_pc(entry_F);
END global_branch_predictor_behaviour;
