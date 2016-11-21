LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cache_data IS
	PORT (	clk		 : IN STD_LOGIC;
			reset	 : IN STD_LOGIC;
			addr	 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in	 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			we		 : IN STD_LOGIC;
			hit		 : OUT STD_LOGIC;
			done	 : OUT STD_LOGIC;
			mem_req	 : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we	 : OUT STD_LOGIC;
			mem_busy : IN STD_LOGIC;
			mem_done : IN STD_LOGIC;
			mem_data_in	 : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_data_out : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END cache_data;

ARCHITECTURE cache_data_behavior OF cache_data IS
	CONSTANT ADDR_BITS	 : INTEGER := 32;
	CONSTANT TAG_BITS	 : INTEGER := 28;
	CONSTANT DATA_BITS	 : INTEGER := 128;
	CONSTANT CACHE_LINES : INTEGER := 4;

	TYPE state_t IS (READY, LINEREQ, LINEREPL);

	TYPE lru_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF INTEGER RANGE 0 to 3;
	TYPE valid_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE dirty_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE tag_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(TAG_BITS-1 DOWNTO 0);
	TYPE data_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	TYPE hit_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;

	COMPONENT comp_28bits
		PORT(	input1 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
				input2 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
				output : OUT STD_LOGIC);
	END COMPONENT;

	-- Determine the state of the cache:
	-- READY: The cache will be ready to execute a new instruction in the next cycle.
	-- LINEREQ: The cache is waiting to get a memory line from the memory. The cache
	-- won't be ready to execute a new instruction in the next cycle.
	-- LINEREPL: The cache has sent a dirty line to the memory, which has been replaced.
	-- It won't be ready to execute a new instruction in the next cycle.
	SIGNAL state : state_t;

	-- Fields of the cache
	SIGNAL lru_fields	: lru_fields_t;
	SIGNAL valid_fields	: valid_fields_t;
	SIGNAL dirty_fields	: dirty_fields_t;
	SIGNAL tag_fields	: tag_fields_t;
	SIGNAL data_fields	: data_fields_t;

	-- Determine for each line whether hits the tag or not
	SIGNAL hit_tag : hit_t;

	-- Determine for each line whether hits or not
	SIGNAL hit_line : hit_t;

	-- Determines whether there is a hit or not in the cache
	SIGNAL hit_cache : STD_LOGIC;

	-- Determine the line which has hit
	SIGNAL hit_line_number : STD_LOGIC_VECTOR(2 DOWNTO 0) := "00";
BEGIN

stage : process(clk)

END PROCESS reset;

-- Process to reset the cache
reset : process(clk, reset)
	nline : INTEGER := 0;
BEGIN
	IF rising_edge(clk) AND reset = '1' THEN
		-- Initialize LRU and valid fields
		WHILE nline /= CACHE_LINES LOOP
			lru_fields(nline) = nline;
			valid_fields(nline) = '0';
			nline <= nline + 1;
		END LOOP;
		state = READY;
	END IF;
END PROCESS reset;

-- Comparators to determine if the tags are the same
hit_tag_loop : FOR i IN 0 TO 3 GENERATE
	comp : comp_28bits PORT MAP(tag_fields(i), addr(31 DOWNTO 4), hit_tag(i));
END GENERATE;

c0 : comp_28bits PORT MAP(tag_fields(0), addr(31 DOWNTO 4), hit_tag(0));
c1 : comp_28bits PORT MAP(tag_fields(1), addr(31 DOWNTO 4), hit_tag(1));
c2 : comp_28bits PORT MAP(tag_fields(2), addr(31 DOWNTO 4), hit_tag(2));
c3 : comp_28bits PORT MAP(tag_fields(3), addr(31 DOWNTO 4), hit_tag(3));

-- Logic to determine if a cache line has a hit or a miss
hit_line_loop : FOR i IN 0 TO 3 GENERATE
	hit_line(i) <= valid_fields(i) AND hit_tag(i);
END GENERATE;

hit_line(0) <= valid_fields(0) AND hit_tag(0);
hit_line(1) <= valid_fields(1) AND hit_tag(1);
hit_line(2) <= valid_fields(2) AND hit_tag(2);
hit_line(3) <= valid_fields(3) AND hit_tag(3);

-- Logic to determine if the cache has a hit or a miss
hit_cache <= hit_line(0) AND hit_line(1) AND hit_line(2) AND hit_line(3);

-- Conditional assignment to know which line has a hit
hit_line_number <=	"00" WHEN (hit_line(0) = '1') ELSE
					"01" WHEN (hit_line(1) = '1') ELSE
					"10" WHEN (hit_line(2) = '1') ELSE
					"11";

-- Set output ports
hit <= hit_cache;
data_out <= data_fields(to_integer(unsigned(hit_line_number)));

END cache_data_behavior;
