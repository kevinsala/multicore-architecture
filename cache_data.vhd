LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY cache_data IS
	PORT(
		clk      : IN STD_LOGIC;
		reset    : IN STD_LOGIC;
		addr     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		we       : IN STD_LOGIC;
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

	-- Determine whether the access has hit, which line and its data
	SIGNAL hit : STD_LOGIC := '1';

	-- Determine the target line of the access
	SIGNAL target_line : INTEGER RANGE 0 TO 3 := 0;

	-- Determine the target word of the line
	SIGNAL target_word : INTEGER RANGE 0 TO 3 := 0;


	-- Procedure to reset and initialize the cache
	PROCEDURE reset_cache(
			SIGNAL state : OUT state_t;
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

	PROCEDURE get_target_word(
			SIGNAL addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			VARIABLE word : OUT INTEGER RANGE 0 TO 3
		) IS
	BEGIN
		CASE addr(3 DOWNTO 0) IS
			WHEN x"0" => word := 0;
			WHEN x"4" => word := 1;
			WHEN x"8" => word := 2;
			WHEN x"C" => word := 3;
			WHEN OTHERS => word := 0;
		END CASE;
	END PROCEDURE;
BEGIN

execution : PROCESS(clk)
	VARIABLE hit_i : STD_LOGIC;
	VARIABLE replacement_i : STD_LOGIC;
	VARIABLE target_line_i : INTEGER RANGE 0 TO 3;
	VARIABLE target_word_i : INTEGER RANGE 0 TO 3;
	VARIABLE msb_pos : INTEGER RANGE 0 TO 127;
	VARIABLE lsb_pos : INTEGER RANGE 0 TO 127;
	VARIABLE serve_access : BOOLEAN;
BEGIN
	serve_access := FALSE;

	IF rising_edge(clk) THEN
		IF reset = '0' THEN
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
						mem_data_out <= data_fields(target_line_i);
						mem_we <= '1';
					ELSE
						state <= LINEREQ;
						mem_addr <= addr;
						mem_we <= '0';
					END IF;
					mem_req	<= '1';
				END IF;

				hit <= hit_i;
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
				get_target_word(addr, target_word_i);

				IF we = '1' THEN
					msb_pos := (target_word_i + 1) * WORD_BITS - 1;
					lsb_pos := target_word_i * WORD_BITS;

					dirty_fields(target_line_i) <= '1';
					data_fields(target_line_i)(msb_pos DOWNTO lsb_pos) <= data_in;
				END IF;
				LRU_execute(lru_fields, target_line_i);

				hit <= '1';
				target_word <= target_word_i;
			END IF;
		ELSE reset_cache(state, lru_fields, valid_fields, dirty_fields, mem_req, mem_we);
		END IF;
	END IF;
END PROCESS execution;

-- Set the data_out port to the requested word
WITH target_word SELECT data_out <=
		data_fields(target_line)(31  DOWNTO  0) WHEN 0,
		data_fields(target_line)(63  DOWNTO 32) WHEN 1,
		data_fields(target_line)(95  DOWNTO 64) WHEN 2,
		data_fields(target_line)(127 DOWNTO 96) WHEN 3,
		data_fields(target_line)(31  DOWNTO  0) WHEN OTHERS;

-- The cache has completed an operation when the access is a hit
done <= hit;

END cache_data_behavior;
