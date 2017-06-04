LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY cache_last_level IS
	PORT (
		clk          : IN    STD_LOGIC;
		reset        : IN    STD_LOGIC;
		bus_done     : INOUT STD_LOGIC;                      -- LLC-L1 bus signals
		bus_cmd      : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		bus_addr     : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		bus_data     : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_done     : IN    STD_LOGIC;                      -- LLC-Mem signals
		mem_cmd      : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
		mem_addr     : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data     : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		arb_req      : OUT   STD_LOGIC;
		arb_ack      : IN    STD_LOGIC
	);
END cache_last_level;

ARCHITECTURE cache_last_level_behavior OF cache_last_level IS

	TYPE data_fields_t  IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
	TYPE valid_fields_t IS ARRAY(31 DOWNTO 0) OF STD_LOGIC;                      -- Whether a block has valid data
	TYPE tag_fields_t   IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(27 DOWNTO 0);  -- Whether a block is present
	TYPE avail_fields_t IS ARRAY(31 DOWNTO 0) OF STD_LOGIC;                      -- Whether data in the block is available
	
	-- Each line maps to a value in range 0..31 for the LRU algorithm
	TYPE lru_fields_t   IS ARRAY(31 DOWNTO 0) OF INTEGER RANGE 0 TO 31;
	
	
	-- Fields of the LLC
	SIGNAL data_fields  : data_fields_t;
	SIGNAL valid_fields : valid_fields_t;
	SIGNAL tag_fields   : tag_fields_t;
	SIGNAL avail_fields : avail_fields_t;
	SIGNAL lru_fields   : lru_fields_t;

	-- The next state of the cache
	SIGNAL state_i    : cache_last_level_state_t;
	SIGNAL state_nx_i : cache_last_level_state_t;
	
	-- Determine:
	-- 1 - If there's a hit              -> (VALID == 1 && TAG == ADDR)
	-- 3 - Which line has hit            -> Number representing the hit line
	-- 2 - If the hit block is available -> (VALID == 1 && TAG == ADDR && AVAIL(hit_line_num_i) == 1)
	SIGNAL hit_i          : STD_LOGIC := '0';
	SIGNAL hit_line_num_i : INTEGER RANGE 0 TO 31 := 0;
	SIGNAL hit_avail_i    : STD_LOGIC := '0';

	-- Replacement signals
	SIGNAL repl_i         : STD_LOGIC := '0';
	SIGNAL repl_addr_i    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL repl_avail_i   : STD_LOGIC := '0';
	SIGNAL lru_line_num_i : INTEGER RANGE 0 TO 31 := 0;

	-- Temporary signals to store a previous request
	-- Used when:
	--   Cache requests a block, LLC needs to replace an invalid block that
	--   maps to the same address, which means it is valid on the other cache. 
	-- Actions:
	--   Store address requested by cache while faking a request so the other
	--   cache evicts the block.
	SIGNAL tmp_address  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL priority_req : STD_LOGIC := '0';
	
	
	-- Determine if there's a hit
	FUNCTION has_access_hit (
		bus_addr     : STD_LOGIC_VECTOR(31 DOWNTO 0);
		tag_fields   : tag_fields_t;
		valid_fields : valid_fields_t
	) 
	RETURN STD_LOGIC IS
		VARIABLE tmp_return : STD_LOGIC := '0';
		BEGIN
			FOR i IN 0 TO 31 LOOP
				tmp_return := tmp_return OR to_std_logic(valid_fields(i) = '1' AND tag_fields(i) = bus_addr(31 DOWNTO 4));
			END LOOP;
		RETURN tmp_return;
	END has_access_hit;
	
		-- Determine which line has hit
	FUNCTION line_hit (
		bus_addr     : STD_LOGIC_VECTOR(31 DOWNTO 0);
		tag_fields   : tag_fields_t;
		valid_fields : valid_fields_t
	) 
	RETURN INTEGER IS
		VARIABLE tmp_return : INTEGER := 0;
		BEGIN
			FOR i IN 0 TO 31 LOOP
				IF (tag_fields(i) = bus_addr(31 DOWNTO 4) AND valid_fields(i) = '1') THEN
					tmp_return := i;
				END IF;
			END LOOP;
		RETURN tmp_return;
	END line_hit;
	
	-- Determine the least recently used line
	FUNCTION get_lru_line (lru_fields : lru_fields_t) RETURN INTEGER IS
		VARIABLE tmp_return : INTEGER := 0;
		BEGIN
			FOR i IN 0 to 31 LOOP
				IF lru_fields(i) = 31 THEN
					tmp_return := i;
				END IF;
			END LOOP;
		RETURN tmp_return;
	END get_lru_line;	
	
	-- Determine if a replacement is needed
	FUNCTION replace_needed (
		hit_i        : STD_LOGIC;
		valid_fields : valid_fields_t
	) 
	RETURN STD_LOGIC IS
		VARIABLE tmp_return : STD_LOGIC;
		BEGIN
			tmp_return := NOT hit_i;
			FOR i IN 0 TO 31 LOOP
				tmp_return := tmp_return AND valid_fields(i);
			END LOOP;
		RETURN tmp_return;
	END replace_needed;
	
	-- Procedure to reset and initialize the cache
	PROCEDURE reset_cache (
			SIGNAL lru_fields   : OUT lru_fields_t;
			SIGNAL valid_fields : OUT valid_fields_t;
			SIGNAL tmp_address  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			SIGNAL priority_req : OUT STD_LOGIC;
			SIGNAL arb_req      : OUT STD_LOGIC
		) IS
		BEGIN
		-- Initialize LRU and valid fields
		FOR i IN 0 TO 31 LOOP
			lru_fields(i)   <= i;
			valid_fields(i) <= '0';
		END LOOP;
		
		tmp_address  <= (OTHERS => '0');
		priority_req <= '0';
		arb_req      <= '0';
	END PROCEDURE;

	PROCEDURE clear_bus (
			SIGNAL bus_cmd  : OUT STD_LOGIC_VECTOR(2   DOWNTO 0);
			SIGNAL bus_addr : OUT STD_LOGIC_VECTOR(31  DOWNTO 0);
			SIGNAL bus_data : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			SIGNAL bus_done : OUT STD_LOGIC
	) IS
		BEGIN
		bus_cmd  <= (OTHERS => 'Z');
		bus_addr <= (OTHERS => 'Z');
		bus_data <= (OTHERS => 'Z');
		bus_done <= 'Z';
	END PROCEDURE;

	PROCEDURE clear_mem (
			SIGNAL mem_cmd  : OUT STD_LOGIC_VECTOR(2   DOWNTO 0);
			SIGNAL mem_addr : OUT STD_LOGIC_VECTOR(31  DOWNTO 0);
			SIGNAL mem_data : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	) IS
		BEGIN
		mem_cmd  <= (OTHERS => 'Z');
		mem_addr <= (OTHERS => 'Z');
		mem_data <= (OTHERS => 'Z');
	END PROCEDURE;

	-- Procedure to execute the Least Recently Used algorithm
	PROCEDURE LRU_execute (
			SIGNAL lru_fields : INOUT lru_fields_t;
			SIGNAL line_id    : IN INTEGER RANGE 0 TO 31
	) IS
		BEGIN
		FOR i IN 0 TO 31 LOOP
			IF lru_fields(i) < lru_fields(line_id) THEN
				lru_fields(i) <= lru_fields(i) + 1;
			END IF;
		lru_fields(line_id) <= 0;
		END LOOP;
	END PROCEDURE;

	BEGIN

	-- Process that represents the internal register
	internal_register : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				state_i <= READY;
			ELSE
				state_i <= state_nx_i;
			END IF;
		END IF;
	END PROCESS internal_register;
	
	-- Process that computes the next state of the cache
	next_state_process : PROCESS(reset, state_i, mem_done, arb_ack, hit_i, hit_avail_i, repl_i, repl_avail_i, bus_cmd, bus_done)
	BEGIN
		IF reset = '1' THEN
			state_nx_i <= READY;
			
		ELSE
			state_nx_i <= state_i;
			
			IF state_i = READY THEN
				IF priority_req = '1' THEN        -- READY -> ARB_LLC_REQ
					state_nx_i <= ARB_LLC_REQ;
					
				ELSIF (bus_cmd = CMD_GET_RO OR bus_cmd = CMD_GET) THEN
					IF hit_i = '1' THEN
						state_nx_i <= READY;          -- READY -> READY
					ELSE
						IF repl_i = '1' THEN
							IF repl_avail_i = '1' THEN
								state_nx_i <= MEM_STORE;  -- READY -> MEM_STORE
							ELSE
								state_nx_i <= MEM_REQ;    -- READY -> MEM_REQ
							END IF;
						ELSE
							state_nx_i <= MEM_REQ;      -- READY -> MEM_REQ
						END IF;
					END IF;
					
				ELSIF (bus_cmd = CMD_PUT) THEN
					state_nx_i <= READY;            -- READY -> READY
				END IF;
						
			ELSIF state_i = MEM_REQ THEN
				IF mem_done = '1' THEN
					state_nx_i <= READY;            -- MEM_REQ -> READY
				END IF;
			
			ELSIF state_i = MEM_STORE THEN
				IF mem_done = '1' THEN
					state_nx_i <= MEM_REQ;          -- MEM_STORE -> MEM_REQ
				END IF;
			
			ELSIF state_i = ARB_LLC_REQ THEN
				IF arb_ack = '1' THEN
					state_nx_i <= BUS_WAIT;         -- ARB_LLC_REQ -> BUS_WAIT
				END IF;
			
			ELSIF state_i = BUS_WAIT THEN
				IF bus_done = '1' THEN
					state_nx_i <= FORCED_STORE;     -- BUS_WAIT -> FORCED_STORE
				END IF;
			
			ELSIF state_i = FORCED_STORE THEN
				IF mem_done = '1' THEN
					state_nx_i <= READY;            -- FORCED_STORE -> READY
				END IF;
			END IF;
		END IF;
	END PROCESS next_state_process;

	-- Process that sets the output signals of the cache
	execution_process : PROCESS(clk)
	VARIABLE can_clear_mem : BOOLEAN;
	VARIABLE can_clear_bus : BOOLEAN;
	BEGIN
		can_clear_mem := TRUE;
		can_clear_bus := TRUE;
		
		IF rising_edge(clk) AND reset = '1' THEN
			reset_cache(lru_fields, valid_fields, tmp_address, priority_req, arb_req);
			clear_bus(bus_cmd, bus_addr, bus_data, bus_done);
			clear_mem(mem_cmd, mem_addr, mem_data);
		
		ELSIF falling_edge(clk) AND reset = '0' THEN
			IF state_i = READY THEN
				IF state_nx_i = MEM_STORE THEN
					mem_cmd  <= CMD_PUT;
					mem_addr <= repl_addr_i;
					mem_data <= data_fields(lru_line_num_i);
					avail_fields(lru_line_num_i) <= '0';
					can_clear_mem := FALSE;
					
				ELSIF state_nx_i = MEM_REQ THEN
					IF (hit_i = '0' AND repl_i = '1' AND repl_avail_i = '0') THEN
						-- Save current state, must fake a request
						priority_req <= '1';
						tmp_address  <= repl_addr_i;
					END IF;
					mem_cmd  <= CMD_GET;
					mem_addr <= bus_addr;
					can_clear_mem := FALSE;
					
				ELSIF state_nx_i = ARB_LLC_REQ THEN
					arb_req <= '1';
					
				ELSIF state_nx_i = READY THEN
					can_clear_bus := FALSE;
					IF (bus_cmd = CMD_PUT) THEN
						LRU_execute(lru_fields, hit_line_num_i);
						avail_fields(hit_line_num_i) <= '1';
						data_fields(hit_line_num_i) <= bus_data;
						bus_done <= '1';
					ELSIF (bus_cmd = CMD_GET) OR (bus_cmd = CMD_GET_RO) THEN
						IF (hit_i = '1' AND hit_avail_i = '1') THEN
							bus_data <= data_fields(hit_line_num_i);
							bus_done <= '1';
							IF (bus_cmd = CMD_GET) THEN
								avail_fields(hit_line_num_i) <= '0';
							END IF;
						ELSIF (hit_i = '1' AND hit_avail_i = '0' AND bus_cmd = CMD_GET) THEN
							can_clear_bus := TRUE; -- Do nothing, only clear bus - another L1 transfers the data	
						END IF;
					END IF;
				END IF;
					
			ELSIF state_i = MEM_REQ THEN
				IF state_nx_i = READY THEN
					bus_data <= mem_data;
					tag_fields(lru_line_num_i)   <= bus_addr(31 DOWNTO 4);
					valid_fields(lru_line_num_i) <= '1';
					LRU_execute(lru_fields, hit_line_num_i);
					bus_done <= '1';
					can_clear_bus := FALSE;
						
					IF (bus_cmd = CMD_GET_RO) THEN
						data_fields(lru_line_num_i)  <= mem_data;
						avail_fields(lru_line_num_i) <= '1';
					ELSE
						avail_fields(lru_line_num_i) <= '0';
					END IF;
				ELSE
					can_clear_mem := FALSE;
				END IF;
					
			ELSIF state_i = MEM_STORE THEN
				IF state_nx_i = MEM_REQ THEN
					mem_cmd  <= CMD_GET;
					mem_addr <= bus_addr;
				END IF;
				can_clear_mem := FALSE;
	
			ELSIF state_i = ARB_LLC_REQ THEN
				IF state_nx_i = BUS_WAIT THEN
					bus_cmd  <= CMD_GET;
					bus_addr <= tmp_address;
					can_clear_bus := FALSE;
				END IF;
					
			ELSIF state_i = BUS_WAIT THEN
				IF state_nx_i = FORCED_STORE THEN
					mem_cmd  <= CMD_PUT;
					mem_addr <= tmp_address;
					mem_data <= bus_data;
					can_clear_mem := FALSE;
				ELSE
					can_clear_bus := FALSE;
				END IF;
				
			ELSIF state_i = FORCED_STORE THEN
				IF state_nx_i = READY THEN
					bus_done     <= '1';
					priority_req <= '0';
					can_clear_bus := FALSE;
				ELSE
					can_clear_mem := FALSE;
				END IF;
			END IF;
			
			IF can_clear_mem THEN
				clear_mem(mem_cmd, mem_addr, mem_data);
			END IF;
			
			IF can_clear_bus THEN
				clear_bus(bus_cmd, bus_addr, bus_data, bus_done);
			END IF;
		END IF;
	END PROCESS execution_process;
	
	-- Determine if the access has hit
	hit_i <= has_access_hit(bus_addr, tag_fields, valid_fields);
	
	-- Determine which line has hit
	hit_line_num_i <= line_hit(bus_addr, tag_fields, valid_fields);
	
	-- Determine if the hit is in an available block
	hit_avail_i <= (hit_i AND avail_fields(hit_line_num_i));

	-- Determine the least recently used line
	lru_line_num_i <= get_lru_line(lru_fields);

	-- Determine if a replacement is needed
	repl_i       <= replace_needed(hit_i, valid_fields);
	repl_addr_i  <= tag_fields(lru_line_num_i) & "0000";
	repl_avail_i <= (repl_i AND avail_fields(lru_line_num_i));
	
END cache_last_level_behavior;
