LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY cache_inst IS
	PORT (clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		done : OUT STD_LOGIC;
		invalid_access : OUT STD_LOGIC;
		state : IN inst_cache_state_t;
		state_nx : OUT inst_cache_state_t;
		mem_req : OUT STD_LOGIC;
		mem_req_abort : IN STD_LOGIC;
		mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_done : IN STD_LOGIC;
		mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END cache_inst;

ARCHITECTURE structure OF cache_inst IS
	CONSTANT ADDR_BITS	 : INTEGER := 32;
	CONSTANT TAG_BITS	 : INTEGER := 26;
	CONSTANT DATA_BITS	 : INTEGER := 128;
	CONSTANT CACHE_LINES : INTEGER := 4;

	TYPE valid_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE tag_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(TAG_BITS-1 DOWNTO 0);
	TYPE data_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	-- Fields of the cache
	SIGNAL valid_fields	: valid_fields_t;
	SIGNAL tag_fields	: tag_fields_t;
	SIGNAL data_fields	: data_fields_t;

	SIGNAL hit_cache : STD_LOGIC;
	SIGNAL cache_line : INTEGER RANGE 0 TO CACHE_LINES - 1;
	SIGNAL req_word : STD_LOGIC_VECTOR(1 DOWNTO 0);

	SIGNAL invalid_access_i : STD_LOGIC;
	SIGNAL state_nx_i : inst_cache_state_t;
BEGIN
	next_state_process : PROCESS(reset, state, hit_cache, addr, mem_req_abort, mem_done, mem_data_in)
	BEGIN
		IF reset = '1' THEN
			state_nx_i <= READY;
		ELSE
			state_nx_i <= state;
			IF state = READY THEN
				IF hit_cache = '0' AND invalid_access_i = '0' THEN
					state_nx_i <= LINEREQ;
				END IF;
			ELSE
				IF mem_done = '1' OR mem_req_abort = '1' THEN
					state_nx_i <= READY;
				END IF;
			END IF;
		END IF;
	END PROCESS next_state_process;

	execution_process : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) AND reset = '1' THEN
			FOR i IN 0 TO CACHE_LINES - 1 LOOP
				valid_fields(i) <= '0';
			END LOOP;
			mem_req <= '0';
		ELSIF falling_edge(clk) AND reset = '0' THEN
			IF state = LINEREQ AND state_nx_i = READY THEN
				IF mem_req_abort = '0' THEN
					tag_fields(cache_line) <= addr(31 DOWNTO 6);
					valid_fields(cache_line) <= '1';
					data_fields(cache_line) <= mem_data_in;
				END IF;

				mem_req <= '0';
			ELSIF state = READY AND state_nx_i = LINEREQ THEN
				mem_req <= '1';
			END IF;
		END IF;
	END PROCESS execution_process;

	invalid_access_i <= '1' WHEN addr(1 DOWNTO 0) /= "00" ELSE '0';
	cache_line <= to_integer(unsigned(addr(5 DOWNTO 4)));
	hit_cache <= '1' WHEN addr(31 DOWNTO 6) = tag_fields(cache_line) AND valid_fields(cache_line) = '1'
				ELSE '0';

	WITH addr(3 DOWNTO 0) SELECT data_out <=
		data_fields(cache_line)(31 DOWNTO 0) WHEN x"0",
		data_fields(cache_line)(63 DOWNTO 32) WHEN x"4",
		data_fields(cache_line)(95 DOWNTO 64) WHEN x"8",
		data_fields(cache_line)(127 DOWNTO 96) WHEN x"C",
		(OTHERS => 'Z') WHEN OTHERS;

	state_nx <= state_nx_i;
	invalid_access <= invalid_access_i;
	done <= hit_cache;
	mem_addr <= addr;
END structure;

