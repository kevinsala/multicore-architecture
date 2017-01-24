LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY cache_data IS
	PORT(
		clk          : IN STD_LOGIC;
		reset        : IN STD_LOGIC;
		debug_dump   : IN STD_LOGIC;
		addr         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		we           : IN STD_LOGIC;
		is_byte      : IN STD_LOGIC;
		line_num     : IN INTEGER RANGE 0 TO 3;
		line_we      : IN STD_LOGIC;
		line_data    : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		lru_line_num : IN INTEGER RANGE 0 TO 3;
		mem_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END cache_data;

ARCHITECTURE cache_data_behavior OF cache_data IS
	CONSTANT BYTE_BITS : INTEGER := 8;
	CONSTANT WORD_BITS : INTEGER := 32;

	TYPE data_fields_t IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);

	-- Data fields of the cache
	SIGNAL data_fields : data_fields_t;

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

	PROCEDURE dump_cache_d(CONSTANT filename : IN STRING;
						SIGNAL cache_data : IN data_fields_t) IS
		FILE dumpfile : TEXT OPEN write_mode IS filename;
		VARIABLE lbuf : LINE;
	BEGIN
		FOR n_line IN 0 TO 3 LOOP
			-- Hex convert
			hwrite(lbuf, cache_data(n_line));
			-- Write to file
			writeline(dumpfile, lbuf);
		END LOOP;
	END PROCEDURE;
BEGIN

-- Process that sets the output signals of the cache
execution_process : process(clk)
BEGIN
	IF debug_dump = '1' THEN
		dump_cache_d("dump/cache_d", data_fields);
	END IF;

	IF falling_edge(clk) AND reset = '0' THEN
		IF line_we = '1' THEN
			data_fields(line_num) <= line_data;
		END IF;

		IF we = '1' THEN
			IF is_byte = '1' THEN
				data_fields(line_num)(target_byte_msb DOWNTO target_byte_lsb) <= data_in(7 DOWNTO 0);
			ELSE
				data_fields(line_num)(target_word_msb DOWNTO target_word_lsb) <= data_in;
			END IF;
		END IF;
	END IF;
END PROCESS execution_process;

-- Logic to determine which word and byte (the interval of bits) is being accessed
target_byte_num <= to_integer(unsigned(addr(3 DOWNTO 0)));
target_word_num <= target_byte_num / 4;
target_word_msb <= (target_word_num + 1) * WORD_BITS - 1;
target_word_lsb <= target_word_num * WORD_BITS;
target_byte_msb <= (target_byte_num + 1) * BYTE_BITS - 1;
target_byte_lsb <= target_byte_num * BYTE_BITS;

-- The accessed word
target_word_data <= data_fields(line_num)(target_word_msb DOWNTO target_word_lsb);

-- The accessed byte with sign extension
target_byte_data(7 DOWNTO 0) <= data_fields(line_num)(target_byte_msb DOWNTO target_byte_lsb);
target_byte_data(31 DOWNTO 8) <= x"FFFFFF" WHEN target_byte_data(7) = '1'
		ELSE x"000000";

-- The definitive output of the access
WITH is_byte SELECT data_out <= target_byte_data WHEN '1',
		target_word_data WHEN OTHERS;

-- Send to memory the least recently used line
mem_data_out <= data_fields(lru_line_num);

END cache_data_behavior;
