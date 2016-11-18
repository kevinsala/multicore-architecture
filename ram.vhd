LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_textio.all;
USE std.textio.all;

ENTITY ram IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        req : IN STD_LOGIC;
        we : IN STD_LOGIC;
        done : OUT STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ram;

ARCHITECTURE structure OF ram IS
    CONSTANT addr_bits : INTEGER := 32;
    CONSTANT data_bits : INTEGER := 32;
    CONSTANT mem_line_bits: INTEGER := 2;
    CONSTANT depth : INTEGER := 65536;
    CONSTANT depth_bits : INTEGER := 16;
    CONSTANT op_delay : INTEGER := 5; -- In cycles

    TYPE ram_type IS ARRAY(depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(data_bits - 1 DOWNTO 0);
    SIGNAL ram : ram_type;
    
    SIGNAL mem_line : INTEGER := 0;
    SIGNAL cycle : INTEGER := op_delay;
    SIGNAL done_int : STD_LOGIC := '0';

    PROCEDURE load_file(CONSTANT filename : IN STRING;
                        CONSTANT mem_line : IN INTEGER;
                        SIGNAL ram : INOUT ram_type) IS
        file romfile : TEXT open read_mode is filename;
        VARIABLE lbuf : LINE;
        VARIABLE fdata : STD_LOGIC_VECTOR(data_bits - 1 downto 0);
        VARIABLE cur_mem_line : INTEGER := mem_line;
    BEGIN
        WHILE NOT endfile(romfile) LOOP
            -- Read line
            readline(romfile, lbuf);
            -- Hex convert
            hread(lbuf, fdata);
            -- Write to memory
            ram(cur_mem_line) <= fdata;
            cur_mem_line := cur_mem_line + 1;
        END LOOP;
    END PROCEDURE;
BEGIN

    p : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                -- 1024: memory line for position 0x1000 in decimal
                --load_file("memory_boot", 1024, ram);
                -- Load to position 0 until the start address is changed
                load_file("memory_boot", 0, ram);
                -- 2048: memory line for position 0x2000 in decimal
                load_file("memory_exc", 2048, ram);
            ELSE
                --IF rising_edge(req) THEN
                --    done_int <= '0';
                --    cycle <= op_delay;
                --ELSIF cycle = 0 THEN
                --    IF we = '1' THEN
                --        ram(mem_line) <= data_in;
                --    END IF;
                --    done_int <= '1';
                --    mem_line <= to_integer(unsigned(addr(depth_bits + mem_line_bits DOWNTO mem_line_bits)));
                --ELSE
                --    done_int <= '0';
                --    cycle <= cycle - 1;
                --END IF;
            END IF;
        END IF;
    END PROCESS p;

    -- Stub until the processor can wait for memory
    mem_line <= to_integer(unsigned(addr(depth_bits + mem_line_bits DOWNTO mem_line_bits)));
    data_out <= ram(mem_line);
    done <= '1';
    -- End stub
    
    --data_out <= ram(mem_line);
    --done <= done_int;
END structure;
