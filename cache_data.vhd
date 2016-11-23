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

	COMPONENT mux4_32bits
		PORT(
			input0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			input2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			input3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ctrl   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

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

	-- Determines whether the access has hit, which line and its data
	SIGNAL hit : STD_LOGIC;
	SIGNAL hit_line : hit_t;
	SIGNAL hit_line_id : INTEGER RANGE 0 TO 3 := 0;
	SIGNAL hit_line_data : STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	-- Determine if it needs a replacement and which line is the least recently used
	SIGNAL replacement : STD_LOGIC;
	SIGNAL lru_line_id : INTEGER RANGE 0 TO 3;

	-- Determine the desired word of the line
	SIGNAL requested_word : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Procedure to reset the cache
	PROCEDURE reset_cache(
			SIGNAL state : INOUT state_t;
			SIGNAL done : OUT STD_LOGIC;
			SIGNAL lru_fields : INOUT lru_fields_t;
			SIGNAL valid_fields : INOUT valid_fields_t ) IS
	BEGIN
		-- Initialize LRU and valid fields
		FOR i IN 0 TO CACHE_LINES-1 LOOP
			lru_fields(i) <= i;
			valid_fields(i) <= '0';
		END LOOP;

		-- Set ready the cache
		state <= READY;
		done <= '1';
	END PROCEDURE;

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

stage : process(clk)
	VARIABLE target_line_id : INTEGER;
	VARIABLE word : INTEGER RANGE 0 TO 3;
	VARIABLE msb_pos : INTEGER RANGE 0 TO 127;
	VARIABLE lsb_pos : INTEGER RANGE 0 TO 127;
BEGIN
	IF rising_edge(clk) AND reset = '0' THEN
		IF state = READY THEN
			IF hit = '1' THEN
				target_line_id := hit_line_id;
				IF we = '1' THEN
					word := to_integer(unsigned(requested_word));
					msb_pos := (word + 1) * WORD_BITS - 1;
					lsb_pos := word * WORD_BITS;
					data_fields(target_line_id)(msb_pos DOWNTO lsb_pos) <= data_in;
					dirty_fields(target_line_id) <= '1';
				END IF;
				LRU_execute(lru_fields, target_line_id);
				done <= '1';
			ELSE
				IF replacement = '1' THEN
					state <= LINEREPL;
					mem_addr <= tag_fields(lru_line_id) & "0000";
					mem_data_out <= data_fields(lru_line_id);
					mem_we <= '1';
				ELSE
					state <= LINEREQ;
					mem_addr <= addr;
					mem_we <= '0';
				END IF;
				mem_req	<= '1';
				done <= '0';
			END IF;
		ELSIF state = LINEREPL THEN
			IF mem_done = '1' THEN
				state <= LINEREQ;
				mem_addr <= addr;
				mem_we <= '0';
				mem_req <= '1';
			END IF;
		ELSIF state = LINEREQ THEN
			target_line_id := lru_line_id;
			IF mem_done = '1' THEN
				state <= READY;
				mem_req <= '0';
				mem_we <= '0';
				valid_fields(target_line_id) <= '1';
				dirty_fields(target_line_id) <= '0';
				tag_fields(target_line_id) <= addr(31 DOWNTO 4);
				data_fields(target_line_id) <= mem_data_in;
				LRU_execute(lru_fields, target_line_id);
			END IF;
		END IF;
	ELSIF rising_edge(clk) AND reset = '0' THEN
		reset_cache(state, done, lru_fields, valid_fields);
	END IF;
END PROCESS stage;

-- Logic to determine for each cache line if it's the requested line
hit_line_loop : FOR i IN 0 TO 3 GENERATE
	hit_line(i) <= valid_fields(i) AND to_std_logic(tag_fields(i) = addr(31 DOWNTO 4));
END GENERATE;

-- Logic to determine if the access is a hit or a miss
hit <= hit_line(0) OR hit_line(1) OR hit_line(2) OR hit_line(3);

-- Conditional assignment to know which line has hit
hit_line_id <= 0 WHEN hit_line(0) = '1'
				ELSE 1 WHEN hit_line(1) = '1'
				ELSE 2 WHEN hit_line(2) = '1'
				ELSE 3 WHEN hit_line(3) = '1'
				ELSE 0;

-- Conditional assignment to know which line is the least recentrly used
lru_line_id <= 0 WHEN lru_fields(0) = 3
				ELSE 1 WHEN lru_fields(1) = 3
				ELSE 2 WHEN lru_fields(2) = 3
				ELSE 3 WHEN lru_fields(3) = 3
				ELSE 0;

-- Logic to determine if the cache needs a replacement
replacement <= NOT hit AND dirty_fields(lru_line_id) AND valid_fields(0) AND valid_fields(1) AND valid_fields(2) AND valid_fields(3);

-- Get the line which has hit
hit_line_data <= data_fields(hit_line_id);

-- Determine the requested word of the access
WITH addr(3 DOWNTO 0) SELECT requested_word <=
		"00" WHEN x"0",
		"01" WHEN x"4",
		"10" WHEN x"8",
		"11" WHEN x"C",
		"00" WHEN OTHERS;

-- Set the data_out port to the requested word
data_mux : mux4_32bits PORT MAP(hit_line_data(31 DOWNTO 0), hit_line_data(63 DOWNTO 32), hit_line_data(95 DOWNTO 64), hit_line_data(127 DOWNTO 96), requested_word, data_out);


END cache_data_behavior;
