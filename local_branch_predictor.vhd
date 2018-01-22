LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.utils.ALL;

ENTITY local_branch_predictor IS
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
END local_branch_predictor;

ARCHITECTURE local_branch_predictor_behaviour OF local_branch_predictor IS
	CONSTANT LBP_INDEX1_BITS : INTEGER := LBP_ADDR_BITS;
	CONSTANT LBP_INDEX2_BITS : INTEGER := LBP_HIST_BITS;
	CONSTANT LBP_ENTRIES1    : INTEGER := 2 ** LBP_INDEX1_BITS;
	CONSTANT LBP_ENTRIES2    : INTEGER := 2 ** LBP_INDEX2_BITS;

	CONSTANT LBP_ADDR_LSB : INTEGER := 2;
	CONSTANT LBP_ADDR_MSB : INTEGER := LBP_ADDR_LSB + LBP_ADDR_BITS - 1;

	-- First table indexed by the PC
	TYPE pc_fields_t      IS ARRAY(LBP_ENTRIES1-1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE next_pc_fields_t IS ARRAY(LBP_ENTRIES1-1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE history_fields_t IS ARRAY(LBP_ENTRIES1-1 DOWNTO 0) OF STD_LOGIC_VECTOR(LBP_HIST_BITS-1 DOWNTO 0);

	-- Second table indexed by the local history
	TYPE taken_fields_t IS ARRAY(LBP_ENTRIES2-1 DOWNTO 0) OF STD_LOGIC_VECTOR(1 DOWNTO 0);

	SIGNAL pc      : pc_fields_t;
	SIGNAL history : history_fields_t;
	SIGNAL next_pc : next_pc_fields_t;
	SIGNAL taken   : taken_fields_t;

	SIGNAL entry_F   : INTEGER RANGE 0 TO LBP_ENTRIES1-1 := 0;
	SIGNAL entry_A   : INTEGER RANGE 0 TO LBP_ENTRIES1-1 := 0;
	SIGNAL history_F : INTEGER RANGE 0 TO LBP_ENTRIES2-1 := 0;
	SIGNAL history_A : INTEGER RANGE 0 TO LBP_ENTRIES2-1 := 0;
BEGIN
	execution_process : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) AND reset = '1' THEN
			FOR i IN 0 TO LBP_ENTRIES1-1 LOOP
				pc(i) <= (OTHERS => '0');
			END LOOP;
			FOR i IN 0 TO LBP_ENTRIES2-1 LOOP
				taken(i) <= (OTHERS => '0');
			END LOOP;
		ELSIF falling_edge(clk) AND reset = '0' THEN
			IF branch_A = '1' THEN
				IF enable_A = '1' THEN
					IF pc(entry_A) = pc_A THEN
						IF taken_A = '1' AND taken(history_A) /= "11" THEN
							taken(history_A) <= taken(history_A) + "01";
						ELSIF taken_A = '0' AND taken(history_A) /= "00" THEN
							taken(history_A) <= taken(history_A) - "01";
						END IF;
					ELSE
						pc(entry_A) <= pc_A;
						next_pc(entry_A) <= next_pc_A;
						history(entry_A) <= (OTHERS => '0');
						history(entry_A)(0) <= taken_A;
					END IF;
				ELSIF pc(entry_A) = pc_A THEN
					history(entry_A) <= to_stdlogicvector(to_bitvector(history(entry_A)) SLL 1);
					history(entry_A)(0) <= taken_A;
				END IF;
			END IF;
		END IF;
	END PROCESS execution_process;

	entry_F <= to_integer(unsigned(pc_F(LBP_ADDR_MSB DOWNTO LBP_ADDR_LSB)));
	entry_A <= to_integer(unsigned(pc_A(LBP_ADDR_MSB DOWNTO LBP_ADDR_LSB)));

	history_F <= to_integer(unsigned(history(entry_F)));
	history_A <= to_integer(unsigned(info_A(LBP_HIST_BITS-1 DOWNTO 0)));

	info_F(LBP_HIST_BITS-1 DOWNTO 0) <= std_logic_vector(to_unsigned(history_F, LBP_HIST_BITS));
	taken_F <= '1' WHEN taken(history_F) = "10" OR taken(history_F) = "11" ELSE '0';
	next_pc_F <= next_pc(entry_F);
END local_branch_predictor_behaviour;
