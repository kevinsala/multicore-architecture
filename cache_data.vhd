LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.utils.ALL;

ENTITY cache_data IS
	PORT(
		clk      : IN STD_LOGIC;
		reset    : IN STD_LOGIC;
		addr     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		re       : IN STD_LOGIC;
		we       : IN STD_LOGIC;
		is_byte  : IN STD_LOGIC;
		state    : IN data_cache_state_t;
		state_nx : OUT data_cache_state_t;
		done     : OUT STD_LOGIC;
		mem_req  : OUT STD_LOGIC;
		mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we   : OUT STD_LOGIC;
		mem_done : IN STD_LOGIC;
		mem_data_in  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END cache_data;

ARCHITECTURE cache_data_behavior OF cache_data IS
	CONSTANT ADDR_BITS   : INTEGER := 32;
	CONSTANT TAG_BITS    : INTEGER := 28;
	CONSTANT DATA_BITS   : INTEGER := 128;
	CONSTANT BYTE_BITS   : INTEGER := 8;
	CONSTANT WORD_BITS   : INTEGER := 32;
	CONSTANT CACHE_LINES : INTEGER := 4;

	TYPE lru_fields_t   IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF INTEGER RANGE 0 to 3;
	TYPE valid_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE dirty_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE tag_fields_t   IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(TAG_BITS-1 DOWNTO 0);
	TYPE data_fields_t  IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	TYPE hit_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;

	-- Fields of the cache
	SIGNAL lru_fields   : lru_fields_t;
	SIGNAL valid_fields : valid_fields_t;
	SIGNAL dirty_fields : dirty_fields_t;
	SIGNAL tag_fields   : tag_fields_t;
	SIGNAL data_fields  : data_fields_t;

	-- The next state of the cache
	SIGNAL state_nx_i : data_cache_state_t;

	-- Determine the line of the cache that has hit with the access
	SIGNAL hit : STD_LOGIC := '0';
	SIGNAL hit_line : hit_t;
	SIGNAL hit_line_num : INTEGER RANGE 0 TO 3 := 0;

	-- Replacement signals
	SIGNAL replacement : STD_LOGIC := '0';
	SIGNAL lru_line_num : INTEGER RANGE 0 TO 3 := 0;

	-- Determine the target word of the access
	SIGNAL target_word_num : INTEGER RANGE 0 TO 3 := 0;
	SIGNAL target_word_msb : INTEGER RANGE 0 TO 127 := 31;
	SIGNAL target_word_lsb : INTEGER RANGE 0 TO 127 := 0;
	SIGNAL target_word_data : STD_LOGIC_VECTOR(WORD_BITS-1 DOWNTO 0);

	-- Determine the target byte of the access
	SIGNAL target_byte_num : INTEGER RANGE 0 TO 16 := 0;
	SIGNAL target_byte_msb : INTEGER RANGE 0 TO 127 := 7;
	SIGNAL target_byte_lsb : INTEGER RANGE 0 TO 127 := 0;
	SIGNAL target_byte_data : STD_LOGIC_VECTOR(WORD_BITS-1 DOWNTO 0);

	-- Procedure to reset and initialize the cache
	PROCEDURE reset_cache(
			SIGNAL lru_fields : OUT lru_fields_t;
			SIGNAL valid_fields : OUT valid_fields_t;
			SIGNAL dirty_fields : OUT dirty_fields_t;
			SIGNAL mem_req : OUT STD_LOGIC
		) IS
	BEGIN
		-- Initialize LRU and valid fields
		FOR i IN 0 TO CACHE_LINES-1 LOOP
			lru_fields(i) <= i;
			valid_fields(i) <= '0';
			dirty_fields(i) <= '0';
		END LOOP;

		-- Cancel any memory request
		mem_req <= '0';
	END PROCEDURE;

	-- Procedure to execute the Least Recently Used alogrithm
	PROCEDURE LRU_execute(
			SIGNAL lru_fields : INOUT lru_fields_t;
			VARIABLE line_id : IN INTEGER RANGE 0 TO 3
		) IS
		VARIABLE old_value : INTEGER RANGE 0 TO 3 := lru_fields(line_id);
	BEGIN
		FOR i IN 0 TO CACHE_LINES-1 LOOP
			IF lru_fields(i) < old_value THEN
				lru_fields(i) <= lru_fields(i) + 1;
			END IF;
		lru_fields(line_id) <= 0;
		END LOOP;
	END PROCEDURE;
BEGIN

-- Process that computes the next state of the cache
next_state_process : process(reset, state, re, we, hit, replacement, mem_done)
BEGIN
	IF reset = '1' THEN
		state_nx_i <= READY;
	ELSE
		state_nx_i <= state;
		IF state = READY THEN
			IF re = '1' OR we = '1' THEN
				IF hit = '1' THEN
					state_nx_i <= READY;
				ELSIF replacement = '1' THEN
					state_nx_i <= LINEREPL;
				ELSE
					state_nx_i <= LINEREQ;
				END IF;
			END IF;

		ELSIF state = LINEREPL THEN
			IF mem_done = '1' THEN
				state_nx_i <= LINEREQ;
			END IF;

		ELSIF state = LINEREQ THEN
			IF mem_done = '1' THEN
				state_nx_i <= READY;
			END IF;
		END IF;
	END IF;
END PROCESS next_state_process;

-- Process that sets the output signals of the cache
execution_process : process(clk)
	VARIABLE serve_access : BOOLEAN;
	VARIABLE request_line : BOOLEAN;
	VARIABLE target_line : INTEGER RANGE 0 TO 3;
BEGIN
	IF rising_edge(clk) AND reset = '1' THEN
		reset_cache(lru_fields, valid_fields, dirty_fields, mem_req);

	ELSIF falling_edge(clk) AND reset = '0' THEN
		serve_access := FALSE;
		request_line := FALSE;

		IF state = READY THEN
			IF state_nx_i = READY THEN
				IF re = '1' OR we = '1' THEN
					target_line := hit_line_num;
					serve_access := TRUE;
				END IF;
			ELSIF state_nx_i = LINEREPL THEN
				mem_req <= '1';
				mem_we <= '1';
				mem_addr <= tag_fields(lru_line_num) & "0000";
			ELSIF state_nx_i = LINEREQ THEN
				request_line := TRUE;
			END IF;
		ELSIF state = LINEREPL THEN
			IF state_nx_i = LINEREQ THEN
				request_line := TRUE;
			END IF;
		ELSIF state = LINEREQ THEN
			IF state_nx_i = READY THEN
				target_line := lru_line_num;
				mem_req <= '0';
				valid_fields(target_line) <= '1';
				dirty_fields(target_line) <= '0';
				tag_fields(target_line) <= addr(31 DOWNTO 4);
				data_fields(target_line) <= mem_data_in;
				serve_access := TRUE;
			END IF;
		END IF;

		IF serve_access THEN
			IF we = '1' THEN
				IF is_byte = '1' THEN
					data_fields(target_line)(target_byte_msb DOWNTO target_byte_lsb) <= data_in(7 DOWNTO 0);
				ELSE
					data_fields(target_line)(target_word_msb DOWNTO target_word_lsb) <= data_in;
				END IF;

				dirty_fields(target_line) <= '1';
			END IF;
			LRU_execute(lru_fields, target_line);
		ELSIF request_line THEN
			mem_req <= '1';
			mem_we <= '0';
			mem_addr <= addr;
		END IF;
	END IF;
END PROCESS execution_process;

-- For each line, determine if the access has hit
hit_line(0) <= valid_fields(0) AND to_std_logic(tag_fields(0) = addr(31 DOWNTO 4));
hit_line(1) <= valid_fields(1) AND to_std_logic(tag_fields(1) = addr(31 DOWNTO 4));
hit_line(2) <= valid_fields(2) AND to_std_logic(tag_fields(2) = addr(31 DOWNTO 4));
hit_line(3) <= valid_fields(3) AND to_std_logic(tag_fields(3) = addr(31 DOWNTO 4));

-- Determine which line has hit
hit_line_num <= 0 WHEN hit_line(0) = '1'
		ELSE 1 WHEN hit_line(1) = '1'
		ELSE 2 WHEN hit_line(2) = '1'
		ELSE 3 WHEN hit_line(3) = '1'
		ELSE 0;

-- Determine if the access has hit
hit <= hit_line(0) OR hit_line(1) OR hit_line(2) OR hit_line(3);

-- Determine the least recently used line
lru_line_num <= 0 WHEN lru_fields(0) = 3
		ELSE 1 WHEN lru_fields(1) = 3
		ELSE 2 WHEN lru_fields(2) = 3
		ELSE 3 WHEN lru_fields(3) = 3
		ELSE 0;

-- Determine if a replacement is needed
replacement <= NOT hit AND dirty_fields(lru_line_num) AND valid_fields(0) AND valid_fields(1) AND valid_fields(2) AND valid_fields(3);

-- Logic to determine which word and byte (the interval of bits) is being accessed
target_byte_num <= to_integer(unsigned(addr(3 DOWNTO 0)));
target_word_num <= target_byte_num / 4;
target_word_msb <= (target_word_num + 1) * WORD_BITS - 1;
target_word_lsb <= target_word_num * WORD_BITS;
target_byte_msb <= (target_byte_num + 1) * BYTE_BITS - 1;
target_byte_lsb <= target_byte_num * BYTE_BITS;

-- The accessed word
target_word_data <= data_fields(hit_line_num)(target_word_msb DOWNTO target_word_lsb);

-- The accessed byte with sign extension
target_byte_data(7 DOWNTO 0) <= data_fields(hit_line_num)(target_byte_msb DOWNTO target_byte_lsb);
target_byte_data(31 DOWNTO 8) <= x"FFFFFF" WHEN target_byte_data(7) = '1'
		ELSE x"000000";

-- The definitive output of the access
WITH is_byte SELECT data_out <= target_byte_data WHEN '1',
		target_word_data WHEN OTHERS;

-- Send to memory the least recently used line
mem_data_out <= data_fields(lru_line_num);

-- Logic of the next state
state_nx <= state_nx_i;

-- The cache has not finished only when a access produces a miss
done <= hit OR NOT(re OR we);

END cache_data_behavior;
