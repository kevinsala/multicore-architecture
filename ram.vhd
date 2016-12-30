LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY ram IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        debug_dump : IN STD_LOGIC;
        req : IN STD_LOGIC;
        we : IN STD_LOGIC;
        done : OUT STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
END ram;

ARCHITECTURE structure OF ram IS
    CONSTANT addr_bits : INTEGER := 32;
    CONSTANT data_bits : INTEGER := 128;
    CONSTANT mem_line_bits: INTEGER := 4;
    CONSTANT depth : INTEGER := 16384;
    CONSTANT depth_bits : INTEGER := 14;
    CONSTANT op_delay : INTEGER := 5; -- In cycles

    TYPE ram_type IS ARRAY(depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(data_bits - 1 DOWNTO 0);
    SIGNAL ram : ram_type;

    SIGNAL mem_line : INTEGER := 0;
    SIGNAL cycle : INTEGER RANGE 0 TO op_delay - 1;

    PROCEDURE load_file(CONSTANT filename : IN STRING;
                        CONSTANT mem_line : IN INTEGER;
                        SIGNAL ram : INOUT ram_type) IS
        file romfile : TEXT OPEN read_mode IS filename;
        VARIABLE lbuf : LINE;
        VARIABLE fdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE cur_mem_line : INTEGER := mem_line;
        VARIABLE cur_line_pos : INTEGER := 0;
    BEGIN
        WHILE NOT endfile(romfile) LOOP
            -- Read line
            readline(romfile, lbuf);
            -- Hex convert
            hread(lbuf, fdata);
            -- Write to memory
            ram(cur_mem_line)(cur_line_pos + 31 DOWNTO cur_line_pos) <= fdata;
            cur_line_pos := cur_line_pos + 32;
            IF cur_line_pos = 128 THEN
                cur_mem_line := cur_mem_line + 1;
                cur_line_pos := 0;
            END IF;
        END LOOP;
    END PROCEDURE;

	PROCEDURE dump_mem(CONSTANT filename : IN STRING;
						SIGNAL ram : IN ram_type) IS
		FILE dumpfile : TEXT OPEN write_mode IS filename;
		VARIABLE lbuf : LINE;
	BEGIN
		FOR n_line IN 0 TO depth - 1 LOOP
			-- Hex convert
			hwrite(lbuf, ram(n_line));
			-- Write to file
			writeline(dumpfile, lbuf);
		END LOOP;
	END PROCEDURE;
BEGIN
    p : PROCESS(clk)
        VARIABLE mem_line_int : INTEGER RANGE 0 TO depth;
    BEGIN
        IF rising_edge(clk) THEN
            IF debug_dump = '1' THEN
                dump_mem("dump/ram", ram);
            END IF;

            IF reset = '1' THEN
                -- 256: memory line for address 0x1000
                load_file("memory_boot", 256, ram);
                -- 512: memory line for address 0x2000
                load_file("memory_system", 512, ram);
                cycle <= op_delay - 1;
            ELSE
                IF req = '1' THEN
                    IF cycle = 0 THEN
                        done <= '1';
                        cycle <= op_delay - 1;
                        mem_line_int := to_integer(unsigned(addr(depth_bits + mem_line_bits DOWNTO mem_line_bits)));
                        mem_line <= mem_line_int;
                        IF we = '1' THEN
                            ram(mem_line_int) <= data_in;
                        END IF;
                    ELSE
                        cycle <= cycle - 1;
                        done <= '0';
                    END IF;
                ELSE
                    cycle <= op_delay - 1;
                    done <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS p;

    data_out <= ram(mem_line);
END structure;
