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
		done         : INOUT STD_LOGIC;                      -- LLC-L1 bus signals
		cmd          : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr         : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		data         : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_done     : IN    STD_LOGIC;                      -- LLC-mem signals
		mem_cmd      : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
		mem_addr     : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data     : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		arb_req      : OUT   STD_LOGIC;
		arb_ack      : IN    STD_LOGIC;
		arb_priority : OUT   STD_LOGIC
	);
END cache_last_level;

ARCHITECTURE cache_last_level_behavior OF cache_last_level IS

	TYPE hit_t          IS ARRAY(31 DOWNTO 0) OF STD_LOGIC;
	TYPE lru_fields_t   IS ARRAY(31 DOWNTO 0) OF INTEGER RANGE 0 to 31;
	TYPE tag_fields_t   IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(27 DOWNTO 0);
	TYPE data_fields_t  IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
	TYPE valid_fields_t IS ARRAY(31 DOWNTO 0) OF STD_LOGIC;

	-- Fields of the LLC
	SIGNAL lru_fields   : lru_fields_t;
	SIGNAL tag_fields   : tag_fields_t;
	SIGNAL data_fields  : data_fields_t;
	SIGNAL valid_fields : valid_fields_t;

	-- The next state of the cache
	SIGNAL state_i    : cache_last_level_state_t;
	SIGNAL state_nx_i : cache_last_level_state_t;

	-- Determine the line of the cache that has hit with the access
	SIGNAL hit_i          : STD_LOGIC := '0';
	SIGNAL hit_line_i     : hit_t;
	SIGNAL hit_line_num_i : INTEGER RANGE 0 TO 31 := 0;

    -- Determine if the hit (if there was a hit) is valid or not
    SIGNAL hit_valid_i : STD_LOGIC := '0';

	-- Replacement signals
	SIGNAL repl_i         : STD_LOGIC := '0';
	SIGNAL repl_addr_i      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL lru_line_num_i : INTEGER RANGE 0 TO 31 := 0;

	-- Temporary signals to store a previous request
	-- Used when:
	--   Cache requests a block, LLC needs to replace an invalid block that
    --   maps to the same address, which means it is valid on the other cache. 
	-- Actions:
	--   Store address requested by cache while faking a request so the other
	--   cache evicts the block.
	SIGNAL temp_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL priority_req : STD_LOGIC := '0';
	
	-- Determine which line has hit
	FUNCTION check_hit(hit_line_i : hit_t) RETURN INTEGER IS
		VARIABLE tmp_return : INTEGER := 0;
		BEGIN
			FOR i IN 0 to 31 LOOP
				IF hit_line_i(i) = '1' THEN
					tmp_return := i;
				END IF;
			END LOOP;
		RETURN tmp_return;
	END check_hit;
	

    -- Determine the least recently used line
	FUNCTION get_lru_line(lru_fields : lru_fields_t) RETURN INTEGER IS
		VARIABLE tmp_return : INTEGER := 0;
		BEGIN
			FOR i IN 0 to 31 LOOP
				IF lru_fields(i) = 31 THEN
					tmp_return := i;
				END IF;
			END LOOP;
		RETURN tmp_return;
	END get_lru_line;


	-- Determine if the access has hit
	FUNCTION has_access_hit(hit_line_i : hit_t) RETURN STD_LOGIC IS
		VARIABLE tmp_return : STD_LOGIC := '0';
		BEGIN
			FOR i IN 0 to 31 LOOP
				tmp_return := tmp_return OR hit_line_i(i);
			END LOOP;
		RETURN tmp_return;
	END has_access_hit;
	
	
	-- For each line, determine if the access has hit
	FUNCTION lines_hit(
		valid_fields : valid_fields_t;
		tag_fields   : tag_fields_t;
		addr         : STD_LOGIC_VECTOR(31 DOWNTO 0)
    ) RETURN hit_t IS
		VARIABLE tmp_return : hit_t;
		BEGIN
			FOR i IN 0 to 31 LOOP
				tmp_return(i) := to_std_logic(tag_fields(i) = addr(31 DOWNTO 4));
			END LOOP;
		RETURN tmp_return;
	END lines_hit;
	
	
	-- Determine if a replacement is needed
	FUNCTION replace_needed(
        hit_i        : STD_LOGIC;
        valid_fields : valid_fields_t) RETURN STD_LOGIC IS
		VARIABLE tmp_return : STD_LOGIC;
		BEGIN
			tmp_return := NOT hit_i;
			FOR i IN 0 to 31 LOOP
				tmp_return := tmp_return AND valid_fields(i);
			END LOOP;
		RETURN tmp_return;
	END replace_needed;
	
	
	-- Procedure to reset and initialize the cache
	PROCEDURE reset_cache (
			SIGNAL lru_fields   : OUT lru_fields_t;
			SIGNAL valid_fields : OUT valid_fields_t;
            SIGNAL temp_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            SIGNAL priority_req : OUT STD_LOGIC;
            SIGNAL arb_priority : OUT STD_LOGIC;
			SIGNAL arb_req      : OUT STD_LOGIC
		) IS
		BEGIN
		-- Initialize LRU and valid fields
		FOR i IN 0 TO 31 LOOP
			lru_fields(i)   <= i;
			valid_fields(i) <= '0';
		END LOOP;
		
		temp_address <= (OTHERS => '0');
		priority_req <= '0';
		arb_req      <= '0';
		arb_priority <= '0';
	END PROCEDURE;

	PROCEDURE clear_bus (
			SIGNAL cmd  : OUT STD_LOGIC_VECTOR(2   DOWNTO 0);
			SIGNAL addr : OUT STD_LOGIC_VECTOR(31  DOWNTO 0);
			SIGNAL data : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			SIGNAL done : OUT STD_LOGIC
		) IS
		BEGIN
		cmd  <= (OTHERS => 'Z');
		addr <= (OTHERS => 'Z');
		data <= (OTHERS => 'Z');
		done <= 'Z';
	END PROCEDURE;

	PROCEDURE clear_mem (
			SIGNAL cmd  : OUT STD_LOGIC_VECTOR(2   DOWNTO 0);
			SIGNAL addr : OUT STD_LOGIC_VECTOR(31  DOWNTO 0);
			SIGNAL data : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		) IS
		BEGIN
		cmd  <= (OTHERS => 'Z');
		addr <= (OTHERS => 'Z');
		data <= (OTHERS => 'Z');
	END PROCEDURE;

	-- Procedure to execute the Least Recently Used algorithm
	PROCEDURE LRU_execute (
			SIGNAL lru_fields : INOUT lru_fields_t;
			SIGNAL line_id    : IN INTEGER RANGE 0 TO 31
		) IS
		VARIABLE old_value : INTEGER RANGE 0 TO 31 := lru_fields(line_id);
		BEGIN
		FOR i IN 0 TO 31 LOOP
			IF lru_fields(i) < old_value THEN
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
	-- States are: READY, ARBREQ, LINEREQ, LINEREPL
	next_state_process : PROCESS(reset, state_i, mem_done, arb_ack, hit_i, hit_valid_i, repl_i, cmd, done)
	BEGIN
		IF reset = '1' THEN
			state_nx_i <= READY;
		ELSE
			state_nx_i <= state_i;
			IF state_i = READY THEN
                IF priority_req = '1' THEN
                    state_nx_i <= ARB_LLC_REQ;
                ELSE
                    IF (cmd = CMD_GET_RO) THEN
                        IF hit_i = '1' THEN
                            state_nx_i <= READY;
                        ELSE
                            IF repl_i = '1' THEN
                                IF hit_valid_i = '1' THEN
                                    state_nx_i <= MEM_STORE;
                                ELSE
                                    state_nx_i <= MEM_REQ;
                                END IF;
                            ELSE
                                state_nx_i <= MEM_REQ;
                            END IF;
                        END IF;
                                   
                    ELSIF (cmd = CMD_GET) THEN
                        IF hit_i = '1' THEN
                            IF hit_valid_i = '1' THEN
                                state_nx_i <= READY;
                            ELSE
                                state_nx_i <= MEM_REQ;
                            END IF;
                        ELSE
                            IF repl_i = '1' THEN
                                IF hit_valid_i = '1' THEN
                                    state_nx_i <= MEM_STORE;
                                ELSE
                                    state_nx_i <= MEM_REQ;
                                END IF;
                            ELSE
                                state_nx_i <= MEM_REQ;
                            END IF;
                        END IF;
                        
                    ELSIF (cmd = CMD_PUT) THEN
                        state_nx_i <= READY;
                    
                    END IF;
                END IF;
            
            ELSIF state_i = MEM_REQ THEN
                IF mem_done = '1' THEN
                    state_nx_i <= READY;
                END IF;
            
            ELSIF state_i = MEM_STORE THEN
                IF mem_done = '1' THEN
                    state_nx_i <= MEM_REQ;
                END IF;
            
            ELSIF state_i = ARB_LLC_REQ THEN
                IF arb_ack = '1' THEN
                    state_nx_i <= BUS_WAIT;
                END IF;
                
            ELSIF state_i = BUS_WAIT THEN
                IF done = '1' THEN
                    state_nx_i <= MEM_DAH;
                END IF;
            
            ELSIF state_i = MEM_DAH THEN
                IF mem_done = '1' THEN
                    state_nx_i <= READY;
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
			reset_cache(lru_fields, valid_fields, temp_address, priority_req, arb_priority, arb_req);
			clear_bus(cmd, addr, data, done);
			clear_mem(mem_cmd, mem_addr, mem_data);

		ELSIF falling_edge(clk) AND reset = '0' THEN
            IF state_i = READY THEN
                IF state_nx_i = MEM_STORE THEN
                    mem_cmd  <= CMD_PUT;
                    mem_addr <= repl_addr_i;
                    mem_data <= data_fields(lru_line_num_i);
                    valid_fields(lru_line_num_i) <= '0';
					can_clear_mem := FALSE;
                    
                ELSIF state_nx_i = MEM_REQ THEN
                    IF (cmd = CMD_GET_RO) OR (cmd = CMD_GET) THEN
                        IF hit_i = '0' AND repl_i = '1' AND valid_fields(lru_line_num_i) = '0' THEN
                            priority_req <= '1'; -- save state
                            temp_address <= repl_addr_i;
                        END IF;
                    ELSIF (cmd = CMD_GET) THEN
                        IF hit_i = '1' AND valid_fields(lru_line_num_i) = '0' THEN
                            priority_req <= '1'; -- save state
                            temp_address <= repl_addr_i;
                        END IF;
                    END IF;
                    mem_cmd <= CMD_GET;
                    mem_addr <= addr;
					can_clear_mem := FALSE;
                
                ELSIF state_nx_i = ARB_LLC_REQ THEN
                    arb_req <= '1';
		
                ELSIF state_nx_i = READY THEN
                    IF (cmd = CMD_PUT) THEN
                        LRU_execute(lru_fields, hit_line_num_i);
                        valid_fields(hit_line_num_i) <= '1';
                        data_fields(hit_line_num_i) <= data;
                        done <= '1';
                    ELSIF (cmd = CMD_GET) OR (cmd = CMD_GET_RO) THEN
                        data <= data_fields(hit_line_num_i);
                        done <= '1';
                        IF (cmd = CMD_GET) THEN
                            valid_fields(hit_line_num_i) <= '0';
                        END IF;
                    END IF;
					can_clear_bus := FALSE;
                END IF;
		
            ELSIF state_i = MEM_REQ THEN
                IF state_nx_i = READY THEN
                    data <= mem_data;
                    tag_fields(lru_line_num_i) <= addr(31 DOWNTO 4);
                    
                    IF (cmd = CMD_GET_RO) THEN
                        data_fields(lru_line_num_i) <= data;
                        valid_fields(lru_line_num_i) <= '1';
                    ELSE
                        valid_fields(lru_line_num_i) <= '0';
                    END IF;
                    done <= '1';
					can_clear_bus := FALSE;
				ELSE
					can_clear_mem := FALSE;
                END IF;
            
            ELSIF state_i = MEM_STORE THEN
                IF state_nx_i = MEM_REQ THEN
                    mem_cmd <= CMD_GET;
                    mem_addr <= addr;
                END IF;
				can_clear_mem := FALSE;
		
            ELSIF state_i = ARB_LLC_REQ THEN
                IF state_nx_i = BUS_WAIT THEN
                    cmd <= CMD_GET;
                    addr <= temp_address;
					can_clear_bus := FALSE;
                END IF;
            
            ELSIF state_i = BUS_WAIT THEN
                IF state_nx_i = MEM_DAH THEN
                    mem_cmd <= CMD_PUT;
                    mem_addr <= temp_address;
                    mem_data <= data;
					can_clear_mem := FALSE;
				ELSE
					can_clear_bus := FALSE;
                END IF;
                
            ELSIF state_i = MEM_DAH THEN
                IF state_nx_i = READY THEN
                    done <= '1';
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
				clear_bus(cmd, addr, data, done);
			END IF;
        END IF;
	END PROCESS execution_process;

	
	-- For each line, determine if the access has hit
	hit_line_i <= lines_hit(valid_fields, tag_fields, addr);

	-- Determine which line has hit
	hit_line_num_i <= check_hit(hit_line_i);

	-- Determine if the access has hit
	hit_i <= has_access_hit(hit_line_i);
	
    -- Determine if the hit (if there was one) is valid
    hit_valid_i <= valid_fields(hit_line_num_i);

	-- Determine the least recently used line
	lru_line_num_i <= get_lru_line(lru_fields);

	-- Determine if a replacement is needed
	repl_i <= replace_needed(hit_i, valid_fields);
	repl_addr_i <= tag_fields(lru_line_num_i) & "0000";
END cache_last_level_behavior;
