LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.utils.ALL;

ENTITY store_buffer IS
	PORT(
		clk            : IN  STD_LOGIC;
		reset          : IN  STD_LOGIC;
		addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		re             : IN  STD_LOGIC;
		we             : IN  STD_LOGIC;
		is_byte        : IN  STD_LOGIC;
		invalid_access : IN  STD_LOGIC;
		id             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		sleep          : IN  STD_LOGIC;
		repl           : IN  STD_LOGIC;
		repl_addr      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		done           : OUT STD_LOGIC;
		hit            : OUT STD_LOGIC;
		cache_addr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		cache_we       : OUT STD_LOGIC;
		cache_is_byte  : OUT STD_LOGIC;
		cache_data     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		store_id       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		store_commit   : IN  STD_LOGIC;
		squash         : IN  STD_LOGIC
	);
END store_buffer;

ARCHITECTURE store_buffer_behavior OF store_buffer IS
	CONSTANT SB_ENTRIES : INTEGER := 12;

	TYPE id_fields_t IS ARRAY(SB_ENTRIES - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	TYPE valid_fields_t IS ARRAY(SB_ENTRIES - 1 DOWNTO 0) OF STD_LOGIC;
	TYPE addr_fields_t IS ARRAY(SB_ENTRIES - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE byte_fields_t IS ARRAY(SB_ENTRIES - 1 DOWNTO 0) OF STD_LOGIC;
	TYPE data_fields_t IS ARRAY(SB_ENTRIES - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE hit_t IS ARRAY(SB_ENTRIES - 1 DOWNTO 0) OF STD_LOGIC;

	-- Fields of the store buffer
	SIGNAL id_fields : id_fields_t;
	SIGNAL valid_fields : valid_fields_t;
	SIGNAL addr_fields : addr_fields_t;
	SIGNAL byte_fields : byte_fields_t;
	SIGNAL data_fields : data_fields_t;

	-- State, size and first buffer entry
	SIGNAL size_i : INTEGER RANGE 0 TO SB_ENTRIES;
	SIGNAL size_nx_i : INTEGER RANGE 0 TO SB_ENTRIES;
	SIGNAL head_i : INTEGER RANGE 0 TO SB_ENTRIES - 1;
	SIGNAL head_nx_i : INTEGER RANGE 0 TO SB_ENTRIES - 1;

	-- Determine if there is any replacement conflict
	SIGNAL conflict_i : STD_LOGIC := '0';

	-- Determine the entry of the buffer that has hit with the replaced cache line
	SIGNAL repl_hit_i : STD_LOGIC := '0';
	SIGNAL repl_hit_entry_i : hit_t;

	-- Determine the entry to be commited (used only with OoO)
	SIGNAL commit_entry_num_i : INTEGER RANGE 0 TO SB_ENTRIES - 1 := 0;

	-- Determine if the store buffer has to add a new entry
	SIGNAL add_entry_i : STD_LOGIC;

	-- Procedure to reset and initialize the buffer
	PROCEDURE reset_entries(
			SIGNAL valid_fields : OUT valid_fields_t;
			SIGNAL addr_fields : OUT addr_fields_t;
			SIGNAL byte_fields : OUT byte_fields_t;
			SIGNAL size_nx_i : OUT INTEGER RANGE 0 TO SB_ENTRIES;
			SIGNAL head_nx_i : OUT INTEGER RANGE 0 TO SB_ENTRIES - 1
		) IS
	BEGIN
		-- Initialize valid fields
		FOR i IN 0 TO SB_ENTRIES - 1 LOOP
			valid_fields(i) <= '0';
			addr_fields(i) <= x"FFFFFFFF";
			byte_fields(i) <= '0';
		END LOOP;

		size_nx_i <= 0;
		head_nx_i <= 0;
	END PROCEDURE;

	PROCEDURE output_data(
			SIGNAL size : IN INTEGER RANGE 0 TO SB_ENTRIES;
			SIGNAL head : IN INTEGER RANGE 0 TO SB_ENTRIES - 1;
			SIGNAL addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			SIGNAL addr_fields : IN addr_fields_t;
			SIGNAL data_fields : IN data_fields_t;
			SIGNAL hit : OUT STD_LOGIC;
			SIGNAL data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		) IS
		VARIABLE i : INTEGER RANGE 0 TO SB_ENTRIES - 1;
	BEGIN
		hit <= '0';

		IF size > 0 THEN
			i := (head + size - 1) MOD SB_ENTRIES;

			L : LOOP
				IF addr_fields(i)(31 DOWNTO 2) = addr(31 DOWNTO 2) THEN
					data_out <= data_fields(i);
					hit <= '1';
					EXIT;
				END IF;

				EXIT L WHEN i = head_i;
				i := (i - 1) MOD SB_ENTRIES;
			END LOOP;
		END IF;
	END PROCEDURE;
BEGIN

internal_register : PROCESS(clk, reset)
BEGIN
	IF rising_edge(clk) THEN
		IF reset = '1' THEN
			head_i <= 0;
			size_i <= 0;
		ELSE
			head_i <= head_nx_i;
			size_i <= size_nx_i;
		END IF;
	END IF;
END PROCESS internal_register;

execution_process : PROCESS(clk, reset)
	VARIABLE size : INTEGER RANGE 0 TO SB_ENTRIES;
	VARIABLE head : INTEGER RANGE 0 TO SB_ENTRIES - 1;
	VARIABLE new_entry : INTEGER RANGE 0 TO SB_ENTRIES - 1;
BEGIN
	IF falling_edge(clk) THEN
		IF reset = '1' OR squash = '1' THEN
			reset_entries(valid_fields, addr_fields, byte_fields, size_nx_i, head_nx_i);
		ELSE
			head := head_i;
			size := size_i;

			IF store_commit = '1' THEN
				valid_fields(head) <= '0';
				head := (head + 1) MOD SB_ENTRIES;
				size := size - 1;
			END IF;

			IF add_entry_i = '1' THEN
				new_entry := (head + size) MOD SB_ENTRIES;
				id_fields(new_entry) <= id;
				valid_fields(new_entry) <= '1';
				addr_fields(new_entry) <= addr;
				byte_fields(new_entry) <= is_byte;
				data_fields(new_entry) <= data_in;
				size := size + 1;
			END IF;

			head_nx_i <= head;
			size_nx_i <= size;
		END IF;
	END IF;
END PROCESS execution_process;

-- Determine if there is any replacement conflict
conflict_i <= repl AND repl_hit_i AND NOT sleep;

-- Logic to determine if a new entry has to be added
add_entry_i <= we AND NOT invalid_access AND NOT sleep;

-- Output the newest store that hits
output_data(size_i, head_i, addr, addr_fields, data_fields, hit, data_out);

-- Determine if there is any buffered store waiting to modify the replaced line
repl_generator : FOR i IN 0 TO SB_ENTRIES - 1 GENERATE
	repl_hit_entry_i(i) <= valid_fields(i) AND to_std_logic(addr_fields(i)(31 DOWNTO 4) = repl_addr(31 DOWNTO 4));
END GENERATE repl_generator;

repl_hit_i <= repl_hit_entry_i(0) OR repl_hit_entry_i(1) OR repl_hit_entry_i(2) OR repl_hit_entry_i(3)
		OR repl_hit_entry_i(4) OR repl_hit_entry_i(5) OR repl_hit_entry_i(6) OR repl_hit_entry_i(7)
		OR repl_hit_entry_i(8) OR repl_hit_entry_i(9) OR repl_hit_entry_i(10) OR repl_hit_entry_i(11);

-- Determine the entry to be commited
commit_entry_num_i <= 0 WHEN id_fields(0) = store_id AND valid_fields(0) = '1'
		ELSE 1 WHEN id_fields(1) = store_id AND valid_fields(1) = '1'
		ELSE 2 WHEN id_fields(2) = store_id AND valid_fields(2) = '1'
		ELSE 3 WHEN id_fields(3) = store_id AND valid_fields(3) = '1'
		ELSE 4 WHEN id_fields(4) = store_id AND valid_fields(4) = '1'
		ELSE 5 WHEN id_fields(5) = store_id AND valid_fields(5) = '1'
		ELSE 6 WHEN id_fields(6) = store_id AND valid_fields(6) = '1'
		ELSE 7 WHEN id_fields(7) = store_id AND valid_fields(7) = '1'
		ELSE 8 WHEN id_fields(8) = store_id AND valid_fields(8) = '1'
		ELSE 9 WHEN id_fields(9) = store_id AND valid_fields(9) = '1'
		ELSE 10 WHEN id_fields(10) = store_id AND valid_fields(10) = '1'
		ELSE 11 WHEN id_fields(11) = store_id AND valid_fields(11) = '1'
		ELSE 0;

-- Logic to commit a buffered store
cache_we <= store_commit;
cache_addr <= addr_fields(head_i);
cache_is_byte <= byte_fields(head_i);
cache_data <= data_fields(head_i);

-- Determine if the store buffer has finished
done <= NOT conflict_i;

END store_buffer_behavior;
