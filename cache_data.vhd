LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

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
		mem_busy : IN STD_LOGIC;
		mem_done : IN STD_LOGIC;
		mem_data_in  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END cache_data;

ARCHITECTURE cache_data_behavior OF cache_data IS
	CONSTANT ADDR_BITS   : INTEGER := 32;
	CONSTANT TAG_BITS    : INTEGER := 28;
	CONSTANT DATA_BITS   : INTEGER := 128;
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
	SIGNAL state : state_t;

	-- Fields of the cache
	SIGNAL lru_fields   : lru_fields_t;
	SIGNAL valid_fields : valid_fields_t;
	SIGNAL dirty_fields : dirty_fields_t;
	SIGNAL tag_fields   : tag_fields_t;
	SIGNAL data_fields  : data_fields_t;

	-- Determine for each line whether hits or not
	SIGNAL hit_line : hit_t;

	-- Determines whether there is a hit or not in the cache
	SIGNAL hit : STD_LOGIC;

	-- Determine the line which has hit
	SIGNAL hit_line_number : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";

	-- Line that has hit
	SIGNAL line_out : STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	-- Determine the desired word of the line
	SIGNAL requested_word : STD_LOGIC_VECTOR(1 DOWNTO 0);

	FUNCTION to_std_logic(value : BOOLEAN) RETURN std_logic IS
	BEGIN
		IF value THEN
			RETURN('1');
		ELSE
			RETURN('0');
		END IF;
	END FUNCTION to_std_logic;
BEGIN

stage : process(clk)
BEGIN

END PROCESS stage;

-- Process to reset the cache
reset_process : process(clk, reset)
BEGIN
	IF rising_edge(clk) AND reset = '1' THEN

		-- Initialize LRU and valid fields
		FOR i IN 0 TO CACHE_LINES-1 LOOP
			lru_fields(i) <= i;
			valid_fields(i) <= '0';
		END LOOP;

		-- Set the initial state of the cache
		state <= READY;
	END IF;
END PROCESS reset_process;

-- Logic to determine for each cache line if it's the requested line
hit_line_loop : FOR i IN 0 TO 3 GENERATE
	hit_line(i) <= valid_fields(i) AND to_std_logic(tag_fields(i) = addr(31 DOWNTO 4));
END GENERATE;

-- Logic to determine if the access is a hit or a miss
hit <= hit_line(0) OR hit_line(1) OR hit_line(2) OR hit_line(3);

-- Conditional assignment to know which line has hit
hit_line_number <= "00" WHEN (hit_line(0) = '1')
				ELSE "01" WHEN (hit_line(1) = '1')
				ELSE "10" WHEN (hit_line(2) = '1')
				ELSE "11" WHEN (hit_line(3) = '1')
				ELSE "00";

-- Get the line which has hit
line_out <= data_fields(to_integer(unsigned(hit_line_number)));

-- Determine the requested word of the access
requested_word <= "00" WHEN addr(3 DOWNTO 0) = x"0"
				ELSE "01" WHEN addr(3 DOWNTO 0) = x"4"
				ELSE "10" WHEN addr(3 DOWNTO 0) = x"8"
				ELSE "11" WHEN addr(3 DOWNTO 0) = x"C"
				ELSE "00";

-- Set the data_out port to the requested word
data_mux : mux4_32bits PORT MAP(line_out(31 DOWNTO 0), line_out(63 DOWNTO 32), line_out(95 DOWNTO 64), line_out(127 DOWNTO 96), requested_word, data_out);

END cache_data_behavior;
