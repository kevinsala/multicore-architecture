LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY tlb IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		debug_dump : IN STD_LOGIC;
		mem_access : IN STD_LOGIC;
		VA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_r : IN STD_LOGIC;
		PA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		tlb_hit_out : OUT STD_LOGIC;
		priv_status_w : IN STD_LOGIC;
		tlb_we : IN STD_LOGIC;
		data_in : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
	);
END tlb;

ARCHITECTURE structure OF tlb IS
	TYPE tlb_entries IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(19 DOWNTO 0);
	TYPE valid_fields_t IS ARRAY(3 DOWNTO 0) OF STD_LOGIC;
	TYPE lru_fields_t IS ARRAY(3 DOWNTO 0) OF INTEGER RANGE 0 to 3;
	TYPE hit_t IS ARRAY(3 DOWNTO 0) OF STD_LOGIC;

	SIGNAL tlb_tags : tlb_entries;
	SIGNAL valid_entries : valid_fields_t;
	SIGNAL lru_fields : lru_fields_t;

	SIGNAL lru_line_num_i : INTEGER RANGE 0 TO 3 := 0;
	SIGNAL tlb_hit : STD_LOGIC;
	SIGNAL hit_line_i : hit_t;
	SIGNAL hit_line_num_i : INTEGER RANGE 0 TO 3 := 0;

	-- Procedure to execute the Least Recently Used alogrithm
	PROCEDURE LRU_execute(
			SIGNAL lru_fields : INOUT lru_fields_t;
			VARIABLE line_id : IN INTEGER RANGE 0 TO 3
		) IS
		VARIABLE old_value : INTEGER RANGE 0 TO 3 := lru_fields(line_id);
	BEGIN
		FOR i IN 0 TO 3 LOOP
			IF lru_fields(i) < old_value THEN
				lru_fields(i) <= lru_fields(i) + 1;
			END IF;
		lru_fields(line_id) <= 0;
		END LOOP;
	END PROCEDURE;

	PROCEDURE dump_tlb(CONSTANT filename : IN STRING;
						SIGNAL tlb_tags : IN tlb_entries) IS
		FILE dumpfile : TEXT OPEN write_mode IS filename;
		VARIABLE lbuf : LINE;
	BEGIN
		FOR n_line IN 0 TO 3 LOOP
			-- Hex convert
			hwrite(lbuf, tlb_tags(n_line));
			-- Write to file
			writeline(dumpfile, lbuf);
		END LOOP;
	END PROCEDURE;

BEGIN
	p: PROCESS(clk)
		VARIABLE object_line : INTEGER RANGE 0 TO 3;
	BEGIN
		IF falling_edge(clk) THEN
			IF debug_dump = '1' THEN
				dump_tlb("dump/tlb", tlb_tags);
			END IF;
			IF reset = '1' THEN
				FOR i IN 0 TO 3 LOOP
					tlb_tags(i) <= (OTHERS => '0');
					valid_entries(i) <= '0';
					lru_fields(i) <= i;
				END LOOP;
			ELSE
				IF mem_access = '1' AND priv_status_r = '0' AND tlb_hit = '1' THEN
					object_line := hit_line_num_i;
					LRU_execute(lru_fields, object_line);
				END IF;
				IF priv_status_w = '1' AND tlb_we = '1' THEN
					object_line := lru_line_num_i;
					tlb_tags(object_line) <= data_in;
					valid_entries(object_line) <= '1';
					LRU_execute(lru_fields, object_line);
				END IF;
			END IF;
		END IF;
	END PROCESS p;

	-- For each line, determine if the access has hit
	hit_line_i(0) <= valid_entries(0) AND to_std_logic(tlb_tags(0) = VA(31 DOWNTO 12));
	hit_line_i(1) <= valid_entries(1) AND to_std_logic(tlb_tags(1) = VA(31 DOWNTO 12));
	hit_line_i(2) <= valid_entries(2) AND to_std_logic(tlb_tags(2) = VA(31 DOWNTO 12));
	hit_line_i(3) <= valid_entries(3) AND to_std_logic(tlb_tags(3) = VA(31 DOWNTO 12));

	--tlb_hit <= hit_line_i(0) OR hit_line_i(1) OR hit_line_i(2) OR hit_line_i(3);
	tlb_hit <= '1';

	-- Determine which line has hit
	hit_line_num_i <= 0 WHEN hit_line_i(0) = '1'
		ELSE 1 WHEN hit_line_i(1) = '1'
		ELSE 2 WHEN hit_line_i(2) = '1'
		ELSE 3 WHEN hit_line_i(3) = '1'
		ELSE 0;

	-- Determine the least recently used line
	lru_line_num_i <= 0 WHEN lru_fields(0) = 3
		ELSE 1 WHEN lru_fields(1) = 3
		ELSE 2 WHEN lru_fields(2) = 3
		ELSE 3 WHEN lru_fields(3) = 3
		ELSE 0;

	PA <= VA - x"1000" WHEN tlb_hit = '1' AND priv_status_r = '0' 
		ELSE VA;

	tlb_hit_out <= tlb_hit;
END structure;
