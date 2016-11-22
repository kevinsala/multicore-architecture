LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY cache_inst IS
    PORT (clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		done : OUT STD_LOGIC;
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

	TYPE state_t IS (READY, LINEREQ);

	TYPE valid_fields_t IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC;
	TYPE tag_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(TAG_BITS-1 DOWNTO 0);
	TYPE data_fields_t	IS ARRAY(CACHE_LINES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(DATA_BITS-1 DOWNTO 0);

	-- Determine the state of the cache:
	-- READY: The cache will be ready to execute a new instruction in the next cycle.
	-- LINEREQ: The cache is waiting to get a memory line from the memory. The cache
	-- won't be ready to execute a new instruction in the next cycle.
	SIGNAL state : state_t;

	-- Fields of the cache
	SIGNAL valid_fields	: valid_fields_t;
	SIGNAL tag_fields	: tag_fields_t;
	SIGNAL data_fields	: data_fields_t;

	SIGNAL hit_cache : STD_LOGIC;
	SIGNAL cache_line : INTEGER RANGE 0 TO CACHE_LINES - 1;
	SIGNAL req_word : STD_LOGIC_VECTOR(1 DOWNTO 0);

	SIGNAL mem_req_int : STD_LOGIC := '0';
BEGIN
    p1 : process(clk, reset)
    BEGIN
	    IF rising_edge(clk) THEN
	        IF reset = '1' THEN
	            FOR i IN 0 TO CACHE_LINES - 1 LOOP
		            valid_fields(i) <= '0';
	            END LOOP;
	            state <= READY;
	        ELSE
	            IF state = READY THEN
	                IF hit_cache = '0' THEN
	                    state <= LINEREQ;
	                    mem_req_int <= '1';
	                END IF;
	            ELSIF state = LINEREQ THEN
	                IF mem_done = '1' THEN
	                    state <= READY;
	                    mem_req_int <= '0';
	                    tag_fields(cache_line) <= addr(31 DOWNTO 6);
	                    valid_fields(cache_line) <= '1';
	                    data_fields(cache_line) <= mem_data_in;
	                ELSIF mem_req_abort = '1' THEN
	                    -- Abort memory request when there is a branch mispredict
	                    state <= READY;
	                    mem_req_int <= '0';
	                END IF;
	            END IF;
	        END IF;
	    END IF;
    END PROCESS p1;

    cache_line <= to_integer(unsigned(addr(5 DOWNTO 4)));
    hit_cache <= '1' WHEN addr(31 DOWNTO 6) = tag_fields(cache_line) AND valid_fields(cache_line) = '1'
                ELSE '0';

    WITH addr(3 DOWNTO 0) SELECT data_out <=
        data_fields(cache_line)(31 DOWNTO 0) WHEN x"0",
        data_fields(cache_line)(63 DOWNTO 32) WHEN x"4",
        data_fields(cache_line)(95 DOWNTO 64) WHEN x"8",
        data_fields(cache_line)(127 DOWNTO 96) WHEN x"C",
        (OTHERS => 'Z') WHEN OTHERS;

    done <= hit_cache;
    mem_req <= mem_req_int;
    mem_addr <= addr;
END structure;

