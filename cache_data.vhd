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

	TYPE state_t IS (READY, LINEREQ, LINEREPL);

	TYPE lru_fields_t   IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF INTEGER RANGE 0 to 3;
	TYPE valid_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE dirty_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE tag_fields_t   IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(TAG_BITS-1 DOWNTO 0);
	TYPE data_fields_t  IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	TYPE hit_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;

	-- Determine the state of the cache:
	-- READY: The cache will be ready to execute a new instruction in the next cycle.
	-- LINEREQ: The cache is waiting to get a memory line from the memory. The cache
	-- won't be ready to execute a new instruction in the next cycle.
	-- LINEREPL: The cache has sent a dirty line to the memory, which has been replaced.
	-- It won't be ready to execute a new instruction in the next cycle.
	SIGNAL state : state_t := READY;

	-- Fields of the cache
	SIGNAL lru_fields   : lru_fields_t;
	SIGNAL valid_fields : valid_fields_t;
	SIGNAL dirty_fields : dirty_fields_t;
	SIGNAL tag_fields   : tag_fields_t;
	SIGNAL data_fields  : data_fields_t;

	-- Determine the target line of the access
	SIGNAL target_line : INTEGER RANGE 0 TO 3 := 0;

	-- Determine the target word of the access
	SIGNAL target_word : INTEGER RANGE 0 TO 3 := 0;
	SIGNAL target_word_data : STD_LOGIC_VECTOR(WORD_BITS-1 DOWNTO 0);

	-- Determine the target byte of the access
	SIGNAL target_byte : INTEGER RANGE 0 TO 16 := 0;
	SIGNAL target_byte_data : STD_LOGIC_VECTOR(WORD_BITS-1 DOWNTO 0);

	-- Procedure to reset and initialize the cache
	PROCEDURE reset_cache(
			SIGNAL state : OUT state_t;
			SIGNAL done : OUT STD_LOGIC;
			SIGNAL lru_fields : OUT lru_fields_t;
			SIGNAL valid_fields : OUT valid_fields_t;
			SIGNAL dirty_fields : OUT dirty_fields_t;
			SIGNAL mem_req : OUT STD_LOGIC;
			SIGNAL mem_we  : OUT STD_LOGIC
		) IS
	BEGIN
		-- Initialize LRU and valid fields
		FOR i IN 0 TO CACHE_LINES-1 LOOP
			lru_fields(i) <= i;
			valid_fields(i) <= '0';
			dirty_fields(i) <= '0';
		END LOOP;

		-- Set ready the cache
		state <= READY;
		done <= '1';

		-- Cancel any memory request
		mem_req <= '0';
		mem_we <= '0';
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

	PROCEDURE check_hit(
			SIGNAL addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			SIGNAL valid_fields : IN valid_fields_t;
			SIGNAL tag_fields : IN tag_fields_t;
			VARIABLE hit : OUT STD_LOGIC;
			VARIABLE hit_line_id : OUT INTEGER RANGE 0 TO 3
		) IS
		VARIABLE hit_line : hit_t;
	BEGIN
		FOR i IN 0 TO CACHE_LINES-1 LOOP
			hit_line(i) := valid_fields(i) AND to_std_logic(tag_fields(i) = addr(31 DOWNTO 4));
		END LOOP;

		hit := hit_line(0) OR hit_line(1) OR hit_line(2) OR hit_line(3);

		IF hit_line(0) = '1' THEN hit_line_id := 0;
		ELSIF hit_line(1) = '1' THEN hit_line_id := 1;
		ELSIF hit_line(2) = '1' THEN hit_line_id := 2;
		ELSE hit_line_id := 3;
		END IF;
	END PROCEDURE;

	PROCEDURE check_replacement(
			SIGNAL lru_fields : IN lru_fields_t;
			SIGNAL valid_fields : IN valid_fields_t;
			SIGNAL dirty_fields : IN dirty_fields_t;
			VARIABLE hit : IN STD_LOGIC;
			VARIABLE replacement : OUT STD_LOGIC;
			VARIABLE lru_line_id : INOUT INTEGER RANGE 0 TO 3
		) IS
	BEGIN
		-- Conditional assignment to know which line is the least recentrly used
		IF lru_fields(0) = 3 THEN lru_line_id := 0;
		ELSIF lru_fields(1) = 3 THEN lru_line_id := 1;
		ELSIF lru_fields(2) = 3 THEN lru_line_id := 2;
		ELSE lru_line_id := 3;
		END IF;

		-- Logic to determine if the cache needs a replacement
		replacement := NOT hit AND dirty_fields(lru_line_id) AND valid_fields(0) AND valid_fields(1) AND valid_fields(2) AND valid_fields(3);
	END PROCEDURE;

	PROCEDURE get_target_word_and_byte(
			SIGNAL addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			VARIABLE word : OUT INTEGER RANGE 0 TO 3;
			VARIABLE byte : INOUT INTEGER RANGE 0 TO 15
		) IS
	BEGIN
		byte := to_integer(unsigned(addr(3 DOWNTO 0)));
		word := byte / 4;
	END PROCEDURE;
BEGIN

execution : PROCESS(reset, addr, re, we, is_byte, mem_done)
	VARIABLE hit_i : STD_LOGIC;
	VARIABLE replacement_i : STD_LOGIC;
	VARIABLE target_line_i : INTEGER RANGE 0 TO 3;
	VARIABLE target_word_i : INTEGER RANGE 0 TO 3;
	VARIABLE target_byte_i : INTEGER RANGE 0 TO 15;
	VARIABLE msb : INTEGER RANGE 0 TO 127;
	VARIABLE lsb : INTEGER RANGE 0 TO 127;
	VARIABLE serve_access : BOOLEAN;
BEGIN
	serve_access := FALSE;

	IF clk = '1' THEN
		IF reset = '0' AND (re = '1' OR we = '1') THEN
			target_line_i := target_line;
			-- It's ready to process a new access
			IF state = READY THEN
				check_hit(addr, valid_fields, tag_fields, hit_i, target_line_i);

				IF hit_i = '1' THEN
					serve_access := TRUE;
				ELSE
					check_replacement(lru_fields, valid_fields, dirty_fields, hit_i, replacement_i, target_line_i);
					IF replacement_i = '1' THEN
						state <= LINEREPL;
						mem_addr <= tag_fields(target_line_i) & "0000";
						mem_we <= '1';
					ELSE
						state <= LINEREQ;
						mem_addr <= addr;
						mem_we <= '0';
					END IF;
					mem_req	<= '1';
				END IF;

				done <= hit_i;
				target_line <= target_line_i;

			-- It's waiting for a confirmation of line replacement
			ELSIF state = LINEREPL THEN
				IF mem_done = '1' THEN
					state <= LINEREQ;
					mem_addr <= addr;
					mem_we <= '0';
					mem_req <= '1';
				END IF;

			-- It's waiting for a memory line
			ELSIF state = LINEREQ THEN
				IF mem_done = '1' THEN
					state <= READY;
					mem_req <= '0';
					mem_we <= '0';
					valid_fields(target_line_i) <= '1';
					dirty_fields(target_line_i) <= '0';
					tag_fields(target_line_i) <= addr(31 DOWNTO 4);
					data_fields(target_line_i) <= mem_data_in;
					serve_access := TRUE;
				END IF;
			END IF;

			-- It can serve the access
			IF serve_access THEN
				get_target_word_and_byte(addr, target_word_i, target_byte_i);

				IF we = '1' THEN
					IF is_byte = '1' THEN
						msb := (target_byte_i + 1) * BYTE_BITS - 1;
						lsb := target_byte_i * BYTE_BITS;
						data_fields(target_line_i)(msb DOWNTO lsb) <= data_in(BYTE_BITS-1 DOWNTO 0);
					ELSE
						msb := (target_word_i + 1) * WORD_BITS - 1;
						lsb := target_word_i * WORD_BITS;
						data_fields(target_line_i)(msb DOWNTO lsb) <= data_in;
					END IF;

					dirty_fields(target_line_i) <= '1';
				END IF;
				LRU_execute(lru_fields, target_line_i);

				done <= '1';
				target_word <= target_word_i;
				target_byte <= target_byte_i;
			END IF;

		ELSIF reset = '0' THEN
			done <= '1';
		ELSE
			reset_cache(state, done, lru_fields, valid_fields, dirty_fields, mem_req, mem_we);
		END IF;
	END IF;
END PROCESS execution;

target_word_data <= data_fields(target_line)((target_word+1)*WORD_BITS-1 DOWNTO target_word*WORD_BITS);

target_byte_data(7 DOWNTO 0) <= data_fields(target_line)((target_byte+1)*BYTE_BITS-1 DOWNTO target_byte*BYTE_BITS);
target_byte_data(31 DOWNTO 8) <=
		x"FFFFFF" WHEN target_byte_data(7) = '1' ELSE
		x"000000" WHEN target_byte_data(7) = '0' ELSE
		x"000000";

WITH is_byte SELECT data_out <=
		target_byte_data WHEN '1',
		target_word_data WHEN '0',
		target_word_data WHEN OTHERS;

-- Set the mem_data_out to the target line
mem_data_out <= data_fields(target_line);

END cache_data_behavior;
